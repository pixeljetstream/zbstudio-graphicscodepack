return {
  name = "Collection of components for graphics modules",
  description = "Adds a collection of specs, tools, and interpreters for graphics coding.",
  author = "Christoph Kubisch",
  version = 0.2,
  dependencies = "1.51",

  onRegister = function(self)
    local cwd = wx.wxFileName.GetCwd()
    local scriptFile  = debug.getinfo(1, "S").source:sub(2)
    
    local usedPath = wx.wxFileName(scriptFile):IsRelative() and
      MergeFullPath(self:GetFilePath(), "../"..self:GetFileName()) or 
      MergeFullPath(GetPathWithSep(scriptFile),GetFileName(scriptFile))
      
    --DisplayOutput(usedPath, scriptPath, defaultPath)
    wx.wxFileName.SetCwd(usedPath)
    ide:LoadTool()
    ide:LoadSpec()
    ide:LoadInterpreter()
    ide:LoadAPI()
    if cwd then wx.wxFileName.SetCwd(cwd) end
  end,
}
  