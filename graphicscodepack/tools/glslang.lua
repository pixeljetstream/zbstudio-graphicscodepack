-- Copyright (C) 2008-2017 Christoph Kubisch. All rights reserved.
---------------------------------------------------------

local binpath = ide.config.path.glslangbin or os.getenv("GLSLANG_BIN_PATH") or (os.getenv("VULKAN_SDK") and 
  os.getenv("VULKAN_SDK").."/Bin")

return binpath and {
  fninit = function(frame,menuBar)
    
    if (wx.wxFileName(binpath):IsRelative()) then
      local editorDir = string.gsub(ide.editorFilename:gsub("[^/\\]+$",""),"\\","/")
      binpath = editorDir..binpath
    end

    local myMenu = wx.wxMenu{
      { ID "glslang.compile.input", "&Custom Args", "when set a popup for custom compiler args will be envoked", wx.wxITEM_CHECK },
      { ID "glslang.compile.preproc", "Preprocess File", "Pre-process the files only, resolving #inlcudes", wx.wxITEM_CHECK },
      { },
      { ID "glslang.compile.ext", "Compile from .ext\tCtrl-1", "Compile based on file extension" },
      { ID "glslang.compile.vert", "Compile Vertex", "Compile Vertex shader" },
      { ID "glslang.compile.frag", "Compile Fragment", "Compile Fragment shader" },
      { ID "glslang.compile.geom", "Compile Geometry", "Compile Geometry shader" },
      { ID "glslang.compile.tesc", "Compile T.Ctrl", "Compile T.Ctrl shader" },
      { ID "glslang.compile.tese", "Compile T.Eval", "Compile T.Eval shader" },
      { ID "glslang.compile.comp", "Compile Compute", "Compile Compute shader" },
      { ID "glslang.compile.mesh", "Compile Mesh", "Compile Mesh shader" },
      { ID "glslang.compile.task", "Compile Task", "Compile Task shader" },
      { ID "glslang.compile.rgen", "Compile R. Generation", "Compile Ray Generation shader" },
      { ID "glslang.compile.rint", "Compile R. Intersection", "Compile Ray Intersection shader" },
      { ID "glslang.compile.rahit", "Compile R. Any Hit", "Compile Ray Any Hit shader" },
      { ID "glslang.compile.rchit", "Compile R. Closest Hit", "Compile Ray Closest Hit shader" },
      { ID "glslang.compile.rmiss", "Compile R. Miss", "Compile Ray Miss shader" },
      --{ ID "glslang.compile.rcall", "Compile R. Callable", "Compile Ray Callable shader" },
    }
    menuBar:Append(myMenu, "&GLSLANG")

    local data = {}
    data.customarg = false
    data.separable = false
    data.preproc   = false
    data.custom = ""
    data.domains = {
      [ID "glslang.compile.vert"] = 1,
      [ID "glslang.compile.frag"] = 2,
      [ID "glslang.compile.geom"] = 3,
      [ID "glslang.compile.tesc"] = 4,
      [ID "glslang.compile.tese"] = 5,
      [ID "glslang.compile.comp"] = 6,
      [ID "glslang.compile.mesh"] = 7,
      [ID "glslang.compile.task"] = 8,
      [ID "glslang.compile.rgen"] = 9,
      [ID "glslang.compile.rint"] = 10,
      [ID "glslang.compile.rahit"] = 11,
      [ID "glslang.compile.rchit"] = 12,
      [ID "glslang.compile.rmiss"] = 13,
      --[ID "glslang.compile.rcall"] = 14,
    }
    data.domainprofiles = {
      "vert",
      "frag",
      "geom",
      "tesc",
      "tese",
      "comp",
      "mesh",
      "task",
      "rgen",
      "rint",
      "rahit",
      "rchit",
      "rmiss",
      --"rcall",
    }
    data.domainexts = {
      vert  = 1,
      frag  = 2,
      geom  = 3,
      geo   = 3,
      tesc  = 4,
      tctrl = 4,
      tese  = 5,
      teval = 5,
      comp  = 6,
      mesh  = 7,
      task  = 8,
      rgen  = 9,
      rint  = 10,
      rahit  = 11,
      rchit  = 12,
      rmiss  = 13,
      --rcall  = 14,
    }
    
    data.domaindefs = {
      " -D_VERTEX_SHADER_ -D_IDE_ ",
      " -D_FRAGMENT_SHADER_ -D_IDE_ ",
      " -D_GEOMETRY_SHADER_ -D_IDE_ ",
      " -D_TESS_CONTROL_SHADER_ -D_IDE_ ",
      " -D_TESS_EVALUATION_SHADER_ -D_IDE_ ",
      " -D_COMPUTE_SHADER_ -D_IDE_ ",
      " -D_MESH_SHADER_ -D_IDE_ ",
      " -D_TASK_SHADER_ -D_IDE_ ",
      " -D_RAY_GENERATION_SHADER_ -D_IDE_ ",
      " -D_RAY_INTERSECTION_SHADER_ -D_IDE_ ",
      " -D_RAY_ANY_HIT_SHADER_ -D_IDE_ ",
      " -D_RAY_CLOSEST_HIT_SHADER_ -D_IDE_ ",
      " -D_RAY_MISS_SHADER_ -D_IDE_ ",
      --" -D_RAY_CALLABLE_SHADER_ -D_IDE_ ",
    }
    
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

    -- Compile Arg
    frame:Connect(ID "glslang.compile.input",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.customarg = event:IsChecked()
      end)
    
    frame:Connect(ID "glslang.compile.preproc",wx.wxEVT_COMMAND_MENU_SELECTED,
      function(event)
        data.preproc = event:IsChecked()
      end)
    
    -- Compile
    local function evCompile(event)
      local filename,info = getEditorFileAndCurInfo()
      local editor = ide:GetEditor()
      local glsl = true

      if (not (filename and binpath)) then
        DisplayOutput("Error: GLSLANG Compile: Insufficient parameters (nofile)\n")
        return
      end
      
      local function getDomain(filename)
        local fname = filename:GetFullName()
        for i,v in pairs(data.domainexts) do
          if (fname:match("%."..i)) then
            domain = v
            break
          end
        end
        if (not domain) then
          DisplayOutput("Error: GLSLANG Compile: could not derive domain\n")
        end
        return domain
      end
      
      local function getCompileArg(filename,domain)
        --if (data.preproc) then return '"'..filename:GetFullPath()..'" '
        --else return "-S "..data.domainprofiles[domain]..' "'..filename:GetFullPath()..'" '
        --end
        return "-S "..data.domainprofiles[domain]..' "'..filename:GetFullPath()..'" '
      end

      
      local outname
      local outsuffix
      local compileargs
      local getinstructions
      do
        -- compile single file
        getinstructions = true
        
        local domain = data.domains[event:GetId()]
        if (not domain) then
          domain = getDomain(filename)
        end
        if (not domain) then
          return
        end
        
        local profile   = data.domainprofiles[domain]
        local fullname  = filename:GetFullPath()
        
        outname     = fullname.."."
        outsuffix   = nil
        compileargs = data.domaindefs[domain].." "..getCompileArg(filename,domain)
      end
      
      -- popup for custom input
      data.custom = data.customarg and wx.wxGetTextFromUser("Compiler Args","GLSLANG",data.custom) or data.custom
      local args = data.customarg and data.custom or ""
      args = args:len() > 0 and args or nil

      outname = outname..(args and "^"..args:gsub("%s*[%-%/]",";-")..";^" or "")
      outname = outname..(outsuffix or "")
      outname = outname..((outsuffix or args) and "." or "")
      local logname = outname..'spva'
      outname = '"'..outname..'spv"'
      
      DisplayOutput("logname", logname)

      local cmdline = binpath.."/glslangValidator.exe "
      if (data.preproc) then
        logname = filename:GetPath(wx.wxPATH_GET_VOLUME + wx.wxPATH_GET_SEPARATOR).."_"..filename:GetFullName()
        cmdline = cmdline.."-E "
        cmdline = cmdline..compileargs
      else
        cmdline = cmdline..(args and args.." " or "")
        cmdline = cmdline.."--target-env vulkan1.1 -H "
        cmdline = cmdline.."-o "..outname.." "
        cmdline = cmdline..compileargs
      end
      
      do 
        -- reset log file
        local f = io.open(logname,"wt")
        if (f) then
          f:flush()
          f:close()
        end
      end

      local moduleFile = false
      local function compilecallback(str)
        if (data.preproc or (not moduleFile and str:match("// Module"))) then
          moduleFile = true
        end
        
        if (moduleFile) then
          local f = io.open(logname,"at")
          if (f) then
            local ostr = str:gsub("\n","")
            f:write(ostr)
            f:flush()
            f:close()
          end
          return
        else
          return str
        end
      end
      
      local wdir = filename:GetPath(wx.wxPATH_GET_VOLUME)

      -- run compiler process
      CommandLineRun(cmdline,wdir,true, nil, compilecallback)

    end

    for i,v in pairs(data.domains) do
      frame:Connect(i,wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)
    end
    frame:Connect(ID "glslang.compile.ext",wx.wxEVT_COMMAND_MENU_SELECTED,evCompile)

  end,
}
