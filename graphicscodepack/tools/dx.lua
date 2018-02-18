-- Copyright (C) 2008-2017 Christoph Kubisch. All rights reserved.
---------------------------------------------------------

local binpath = ide.config.path.fxcbin or (os.getenv("DXSDK_DIR") and os.getenv("DXSDK_DIR").."/Utilities/bin/x86/")
local dxprofile

return binpath and {
  fninit = function(frame,menuBar)
    dxprofile = ide.config.dxprofile or "dx_5"
    
    if (wx.wxFileName(binpath):IsRelative()) then
      local editorDir = string.gsub(ide.editorFilename:gsub("[^/\\]+$",""),"\\","/")
      binpath = editorDir..binpath
    end

    local myMenu = wx.wxMenu{
      { ID "dx.profile.dx_2x", "DX SM&2_x", "DirectX sm2_x profile", wx.wxITEM_CHECK },
      { ID "dx.profile.dx_3", "DX SM&3_0", "DirectX sm3_0 profile", wx.wxITEM_CHECK },
      { ID "dx.profile.dx_4", "DX SM&4_0", "DirectX sm4_0 profile", wx.wxITEM_CHECK },
      { ID "dx.profile.dx_5", "DX SM&5_0", "DirectX sm5_0 profile", wx.wxITEM_CHECK },
      --{ ID "dx.profile.dx_6", "DX SM&6_0", "DirectX sm6_0 profile", wx.wxITEM_CHECK },
      { },
      { ID "dx.compile.input", "Custom &Args", "when set a popup for custom compiler args will be envoked", wx.wxITEM_CHECK },
      { ID "dx.compile.binary", "&Binary", "when set compiles binary output", wx.wxITEM_CHECK },
      { ID "dx.compile.legacy", "Legacy", "when set compiles in legacy mode", wx.wxITEM_CHECK },
      { ID "dx.compile.backwards", "Backwards Compatibility", "when set compiles in backwards compatibility mode", wx.wxITEM_CHECK },
      { },
      { ID "dx.compile.any", "Compile from &Entry\tCtrl-3", "Compile Shader (select entry word, matches _?s or ?S suffix for type)" },
      { ID "dx.compile.last", "Compile &Last\tCtrl-4", "Compile Shader using last domain and entry word" },
      { ID "dx.compile.vertex", "Compile &Vertex", "Compile Vertex shader (select entry word)" },
      { ID "dx.compile.pixel", "Compile &Pixel", "Compile Pixel shader (select entry word)" },
      { ID "dx.compile.geometry", "Compile &Geometry", "Compile Geometry shader (select entry word)" },
      { ID "dx.compile.domain", "Compile &Domain", "Compile Domain shader (select entry word)" },
      { ID "dx.compile.hull", "Compile &Hull", "Compile Hull shader (select entry word)" },
      { ID "dx.compile.compute", "Compile &Compute", "Compile Compute shader (select entry word)" },
      { ID "dx.compile.effects", "Compile E&ffects", "Compile all effects in shader" },
    }
    menuBar:Append(myMenu, "&Dx")

    local data = {}
    data.lastentry = nil
    data.lastdomain = nil
    data.customarg = false
    data.custom = ""
    data.legacy = false
    data.backwards = false
    data.binary = false
    data.profid = ID ("dx.profile."..dxprofile)
    data.types = {
      ["vs"] = 1,
      ["ps"] = 2,
      ["gs"] = 3,
      ["ds"] = 4,
      ["hs"] = 5,
      ["cs"] = 6,
    }
    data.domains = {
      [ID "dx.compile.vertex"] = 1,
      [ID "dx.compile.pixel"] = 2,
      [ID "dx.compile.geometry"] = 3,
      [ID "dx.compile.domain"] = 4,
      [ID "dx.compile.hull"] = 5,
      [ID "dx.compile.compute"] = 6,
      [ID "dx.compile.effects"] = 7,
      [ID "dx.compile.last"] = "last",
    }
    data.profiles = {
      [ID "dx.profile.dx_2x"] = {"vs_2_0","ps_2_x",false,false,false,false,"fx_2_x",ext=".fxc."},
      [ID "dx.profile.dx_3"] = {"vs_3_0","ps_3_0",false,false,false,false,"fx_3_0",ext=".fxc."},
      [ID "dx.profile.dx_4"] = {"vs_4_0","ps_4_0","gs_4_0",false,false,false,"fx_4_0",ext=".fxc."},
      [ID "dx.profile.dx_5"] = {"vs_5_0","ps_5_0","gs_5_0","ds_5_0","hs_5_0","cs_5_0","fx_5_0",ext=".fxc."},
      [ID "dx.profile.dx_6"] = {"vs_6_0","ps_6_0","gs_6_0","ds_6_0","hs_6_0","cs_6_0",false,ext=".fxc."},
    }
    data.domaindefs = {
      " /D _VERTEX_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _FRAGMENT_=1 /D _PIXEL_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _GEOMETRY_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _TESS_CONTROL_=1 /D _HULL_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _TESS_EVAL_=1 /D _DOMAIN_=1 /D _DX_=1 /D _IDE_=1 ",
      " /D _COMPUTE_=1 /D _DX_=1 /D _IDE_=1 ",
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
    frame:Connect(ID "dx.compile.input",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.customarg = event:IsChecked()
      end)
    frame:Connect(ID "dx.compile.legacy",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.legacy = event:IsChecked()
      end)
    frame:Connect(ID "dx.compile.backwards",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.backwards = event:IsChecked()
      end)
    frame:Connect(ID "dx.compile.binary",wx.wxEVT_COMMAND_MENU_SELECTED,
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
          if(entry:match("_"..typename) or entry:match("[a-z0-9_]"..string.upper(typename).."$")) then
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

    frame:Connect(ID "dx.compile.any",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.last",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.vertex",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.pixel",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.geometry",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.domain",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.hull",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.compute",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    frame:Connect(ID "dx.compile.effects",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
  end,
}
