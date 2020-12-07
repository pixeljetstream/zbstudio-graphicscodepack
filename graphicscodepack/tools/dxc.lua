-- Copyright (C) 2020 Christoph Kubisch. All rights reserved.
---------------------------------------------------------

local binpath = ide.config.path.dxcbin
local dxprofile

return binpath and {
  fninit = function(frame,menuBar)
    dxprofile = ide.config.dxcprofile or "dx_6_5"
    
    if (wx.wxFileName(binpath):IsRelative()) then
      local editorDir = string.gsub(ide.editorFilename:gsub("[^/\\]+$",""),"\\","/")
      binpath = editorDir..binpath
    end

    local myMenu = wx.wxMenu{
      { ID "dxc.profile.dx_5", "DX SM&5_0", "DirectX sm5_0 profile", wx.wxITEM_CHECK },
      { ID "dxc.profile.dx_6", "DX SM&6_0", "DirectX sm6_0 profile", wx.wxITEM_CHECK },
      { },
      { ID "dxc.compile.input", "Custom &Args", "when set a popup for custom compiler args will be envoked", wx.wxITEM_CHECK },
      { ID "dxc.compile.binary", "&Binary", "when set compiles binary output", wx.wxITEM_CHECK },
      { ID "dxc.compile.backwards", "Backwards Compatibility", "when set compiles in backwards compatibility mode", wx.wxITEM_CHECK },
      { },
      { ID "dxc.compile.any", "Compile from &Entry\tCtrl-3", "Compile Shader (select entry word, matches _?s or ?S suffix for type)" },
      { ID "dxc.compile.last", "Compile &Last\tCtrl-4", "Compile Shader using last domain and entry word" },
      { ID "dxc.compile.vertex", "Compile &Vertex", "Compile Vertex shader (select entry word)" },
      { ID "dxc.compile.pixel", "Compile &Pixel", "Compile Pixel shader (select entry word)" },
      { ID "dxc.compile.geometry", "Compile &Geometry", "Compile Geometry shader (select entry word)" },
      { ID "dxc.compile.domain", "Compile &Domain", "Compile Domain shader (select entry word)" },
      { ID "dxc.compile.hull", "Compile &Hull", "Compile Hull shader (select entry word)" },
      { ID "dxc.compile.compute", "Compile &Compute", "Compile Compute shader (select entry word)" },
      { ID "dxc.compile.effects", "Compile E&ffects", "Compile all effects in shader" },
      { ID "dxc.compile.preprocess", "Preprocess file only", "preprocess the current file" },
    }
    menuBar:Append(myMenu, "D&XC")

    local data = {}
    data.lastentry = nil
    data.lastdomain = nil
    data.customarg = false
    data.custom = ""
    data.backwards = false
    data.binary = false
    data.preprocess = false
    data.profid = ID ("dxc.profile."..dxprofile)
    data.types = {
      ["vs"] = 1,
      ["ps"] = 2,
      ["as"] = 3,
      ["ms"] = 4,
      ["cs"] = 5,
    }
    data.domains = {
      [ID "dxc.compile.vertex"] = 1,
      [ID "dxc.compile.pixel"] = 2,
      [ID "dxc.compile.amp"] = 3,
      [ID "dxc.compile.mesh"] = 4,
      [ID "dxc.compile.compute"] = 5,
      [ID "dxc.compile.last"] = "last",
    }
    data.profiles = {
      [ID "dxc.profile.dx_6_0"] = {"vs_6_0","ps_6_0","as_6_5","ms_6_5","cs_6_0",ext=".dxc."},
      [ID "dxc.profile.dx_6_5"] = {"vs_6_5","ps_6_5","as_6_5","ms_6_5","cs_6_5",ext=".dxc."},
    }
    data.domaindefs = {
      " /D _VERTEX_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _FRAGMENT_SHADER_=1 /D _PIXEL_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _TASK_SHADER_=1 /D _AMPLIFICATION_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _COMPUTE_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
    }
    -- Profile related
    menuBar:Check(data.profid, true)

    local function selectProfile (id)
      for id,profile in pairs(data.profiles) do
        menuBar:Check(id, false)
      end
      menuBar:Check(id, true)
      data.profid = id
    end

    local function evSelectProfile (event)
      local chose = event:GetId()
      selectProfile(chose)
    end

    for id,profile in pairs(data.profiles) do
      frame:Connect(id,wx.wxEVT_COMMAND_MENU_SELECTED,evSelectProfile)
    end

    -- Compile Arg
    frame:Connect(ID "dxc.compile.input",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.customarg = event:IsChecked()
      end)
    frame:Connect(ID "dxc.compile.backwards",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.backwards = event:IsChecked()
      end)
    frame:Connect(ID "dxc.compile.binary",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.binary = event:IsChecked()
      end)
    
    local function getEditorFileAndCurInfo(nochecksave)
      local editor = ide:GetEditor() 
      if (not (editor and (nochecksave or SaveIfModified(editor)))) then
        return
      end

      local id = editor:GetId()
      local filepath = ide.openDocuments[id].filePath
      if not filepath then return end

      local fn = wx.wxFileName(filepath)
      fn:Normalize()

      local info = {}
      info.pos = editor:GetCurrentPos()
      info.line = editor:GetCurrentLine()
      info.sel = editor:GetSelectedText()
      info.sel = info.sel and info.sel:len() > 0 and info.sel or nil
      info.selword = info.sel and info.sel:match("([^a-zA-Z_0-9]+)") or info.sel

      return fn,info
    end
    -- Compile
    local function evCompile(event)
      local filename,info = getEditorFileAndCurInfo()
      local editor = ide:GetEditor()
      local domain = data.domains[event:GetId()]
      local entry  = info.selword
      
      if (domain == "last") then
        domain  = data.lastdomain
        entry   = data.lastentry
      end
      
      if (not domain and entry) then
        for typename,id in pairs(data.types) do
          if(entry:match("_"..typename) or entry:match("[a-z0-9_]"..string.upper(typename).."$") or entry:match("^"..string.lower(typename).."[A-Z]")) then
            domain = id
          end
        end
      end

      if (not (filename and binpath) or  not (domain == 7 or entry )) then
        DisplayOutput("Error: Dx Compile: Insufficient parameters (nofile / no selected entry function!\n")
        return
      end

      data.lastdomain = domain
      data.lastentry  = entry
      
      local profile = data.profiles[data.profid]
      if (not profile[domain]) then
        DisplayOutput("Error: Dx Compile: no profile\n")
        return 
      end

      -- popup for custom input
      data.custom = data.customarg and wx.wxGetTextFromUser("Compiler Args","Dx",data.custom) or data.custom
      local args = data.custom:len() > 0 and data.custom or nil

      local fullname = filename:GetFullPath()

      local outname = fullname.."."..(entry or "").."^"
      outname = args and outname..args:gsub("%s*[%-%/]",";-")..";^" or outname
      outname = outname..profile[domain]..profile.ext..(data.binary and "dxo" or "txt")
      outname = '"'..outname..'"'

      local cmdline = " /T "..profile[domain].." "
      cmdline = cmdline..(args and args.." " or "")
      cmdline = cmdline..(data.backwards and "/Gec " or "")
      cmdline = cmdline..(data.domaindefs[domain])
      cmdline = cmdline..(data.binary and "/Fo " or "/Fc ")..outname.." "
      if (entry) then
      cmdline = cmdline.."/E "..entry.." "
      end
      cmdline = cmdline.."/nologo "
      cmdline = cmdline..' "'..fullname..'"'

      cmdline = '"'..binpath..'/dxc.exe"'..cmdline

      -- run compiler process
      CommandLineRun(cmdline,nil,true,nil,nil)
    end
    
    frame:Connect(ID "dxc.compile.preprocess",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        local filename,info = getEditorFileAndCurInfo()
        
        data.custom = data.customarg and wx.wxGetTextFromUser("Compiler Args","Dx",data.custom) or data.custom
        local args = data.custom:len() > 0 and data.custom or nil
        
        local fullname = filename:GetFullPath()

        local outname = fullname
        outname = args and outname..".^"..args:gsub("%s*[%-%/]",";-")..";^" or outname
        outname = outname..".fx"
        outname = '"'..outname..'"'
        
        local cmdline = " /P "..outname.." "
        cmdline = cmdline..(args and args.." " or "")
        cmdline = cmdline.."/nologo "
        cmdline = cmdline..' "'..fullname..'"'
      
        cmdline = '"'..binpath..'/dxc.exe"'..cmdline
        
        CommandLineRun(cmdline,nil,true,nil,nil)
      end)
    
    frame:Connect(ID "dxc.compile.any",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dxc.compile.last",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dxc.compile.vertex",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dxc.compile.pixel",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dxc.compile.mesh",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dxc.compile.amp",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dxc.compile.compute",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
  end,
}
