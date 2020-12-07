-- Copyright (C) 2008-2020 Christoph Kubisch. All rights reserved.
---------------------------------------------------------

local binpath = ide.config.path.fxcbin or (os.getenv("DXSDK_DIR") and os.getenv("DXSDK_DIR").."/Utilities/bin/x86/")
local dxprofile

return binpath and {
  fninit = function(frame,menuBar)
    dxprofile = ide.config.fxcprofile or "dx_5"
    
    if (wx.wxFileName(binpath):IsRelative()) then
      local editorDir = string.gsub(ide.editorFilename:gsub("[^/\\]+$",""),"\\","/")
      binpath = editorDir..binpath
    end

    local myMenu = wx.wxMenu{
      { ID "fxc.profile.dx_2x", "DX SM&2_x", "DirectX sm2_x profile", wx.wxITEM_CHECK },
      { ID "fxc.profile.dx_3", "DX SM&3_0", "DirectX sm3_0 profile", wx.wxITEM_CHECK },
      { ID "fxc.profile.dx_4", "DX SM&4_0", "DirectX sm4_0 profile", wx.wxITEM_CHECK },
      { ID "fxc.profile.dx_5", "DX SM&5_0", "DirectX sm5_0 profile", wx.wxITEM_CHECK },
      --{ ID "fxc.profile.dx_6", "DX SM&6_0", "DirectX sm6_0 profile", wx.wxITEM_CHECK },
      { },
      { ID "fxc.compile.input", "Custom &Args", "when set a popup for custom compiler args will be envoked", wx.wxITEM_CHECK },
      { ID "fxc.compile.binary", "&Binary", "when set compiles binary output", wx.wxITEM_CHECK },
      { ID "fxc.compile.legacy", "Legacy", "when set compiles in legacy mode", wx.wxITEM_CHECK },
      { ID "fxc.compile.backwards", "Backwards Compatibility", "when set compiles in backwards compatibility mode", wx.wxITEM_CHECK },
      { },
      { ID "fxc.compile.any", "Compile from &Entry", "Compile Shader (select entry word, matches _?s or ?S suffix for type)" },
      { ID "fxc.compile.last", "Compile &Last", "Compile Shader using last domain and entry word" },
      { ID "fxc.compile.vertex", "Compile &Vertex", "Compile Vertex shader (select entry word)" },
      { ID "fxc.compile.pixel", "Compile &Pixel", "Compile Pixel shader (select entry word)" },
      { ID "fxc.compile.geometry", "Compile &Geometry", "Compile Geometry shader (select entry word)" },
      { ID "fxc.compile.domain", "Compile &Domain", "Compile Domain shader (select entry word)" },
      { ID "fxc.compile.hull", "Compile &Hull", "Compile Hull shader (select entry word)" },
      { ID "fxc.compile.compute", "Compile &Compute", "Compile Compute shader (select entry word)" },
      { ID "fxc.compile.effects", "Compile E&ffects", "Compile all effects in shader" },
      { ID "fxc.compile.preprocess", "Preprocess file only", "preprocess the current file" },
    }
    menuBar:Append(myMenu, "FX&C")

    local data = {}
    data.lastentry = nil
    data.lastdomain = nil
    data.customarg = false
    data.custom = ""
    data.legacy = false
    data.backwards = false
    data.binary = false
    data.preprocess = false
    data.profid = ID ("fxc.profile."..dxprofile)
    data.types = {
      ["vs"] = 1,
      ["ps"] = 2,
      ["gs"] = 3,
      ["ds"] = 4,
      ["hs"] = 5,
      ["cs"] = 6,
    }
    data.domains = {
      [ID "fxc.compile.vertex"] = 1,
      [ID "fxc.compile.pixel"] = 2,
      [ID "fxc.compile.geometry"] = 3,
      [ID "fxc.compile.domain"] = 4,
      [ID "fxc.compile.hull"] = 5,
      [ID "fxc.compile.compute"] = 6,
      [ID "fxc.compile.effects"] = 7,
      [ID "fxc.compile.last"] = "last",
    }
    data.profiles = {
      [ID "fxc.profile.dx_2x"] = {"vs_2_0","ps_2_x",false,false,false,false,"fx_2_x",ext=".fxc."},
      [ID "fxc.profile.dx_3"] = {"vs_3_0","ps_3_0",false,false,false,false,"fx_3_0",ext=".fxc."},
      [ID "fxc.profile.dx_4"] = {"vs_4_0","ps_4_0","gs_4_0",false,false,false,"fx_4_0",ext=".fxc."},
      [ID "fxc.profile.dx_5"] = {"vs_5_0","ps_5_0","gs_5_0","ds_5_0","hs_5_0","cs_5_0","fx_5_0",ext=".fxc."},
      [ID "fxc.profile.dx_6"] = {"vs_6_0","ps_6_0","gs_6_0","ds_6_0","hs_6_0","cs_6_0",false,ext=".fxc."},
    }
    data.domaindefs = {
      " /D _VERTEX_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _FRAGMENT_SHADER_=1 /D _PIXEL_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _GEOMETRY_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _TESS_CONTROL_SHADER_=1 /D _HULL_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _TESS_EVALUATION_SHADER_=1 /D _DOMAIN_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _COMPUTE_SHADER_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _EFFECTS_=1 /D _DX_=1 /D _IDE_=1 ",
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
    frame:Connect(ID "fxc.compile.input",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.customarg = event:IsChecked()
      end)
    frame:Connect(ID "fxc.compile.legacy",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.legacy = event:IsChecked()
      end)
    frame:Connect(ID "fxc.compile.backwards",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.backwards = event:IsChecked()
      end)
    frame:Connect(ID "fxc.compile.binary",wx.wxEVT_COMMAND_MENU_SELECTED,
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
      outname = outname..profile[domain]..profile.ext..(data.binary and "fxo" or "txt")
      outname = '"'..outname..'"'

      local cmdline = " /T "..profile[domain].." "
      cmdline = cmdline..(args and args.." " or "")
      cmdline = cmdline..(data.legacy and "/LD " or "")
      cmdline = cmdline..(data.backwards and "/Gec " or "")
      cmdline = cmdline..(data.domaindefs[domain])
      cmdline = cmdline..(data.binary and "/Fo " or "/Fc ")..outname.." "
      if (entry) then
      cmdline = cmdline.."/E "..entry.." "
      end
      cmdline = cmdline.."/nologo "
      cmdline = cmdline..' "'..fullname..'"'

      cmdline = '"'..binpath..'/fxc.exe"'..cmdline

      -- run compiler process
      CommandLineRun(cmdline,nil,true,nil,nil)
    end
    
    frame:Connect(ID "fxc.compile.preprocess",wx.wxEVT_COMMAND_MENU_SELECTED,
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
      
        cmdline = '"'..binpath..'/fxc.exe"'..cmdline
        
        CommandLineRun(cmdline,nil,true,nil,nil)
      end)
    
    frame:Connect(ID "fxc.compile.any",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.last",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.vertex",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.pixel",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.geometry",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.domain",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.hull",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.compute",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "fxc.compile.effects",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
  end,
}
