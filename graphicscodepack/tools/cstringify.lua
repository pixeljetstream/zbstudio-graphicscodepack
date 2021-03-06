-- Copyright (C) 2008-2017 Christoph Kubisch. All rights reserved.
-----------------------------------------------------------------

local function cstringify()
  local editor = ide:GetEditor()
  if (not editor) then end
  local tx = editor:GetText()
  local new = ""
  for l in tx:gmatch("([^\r\n]*)([\r]?[\n]?)") do
    l = l:gsub('\\','\\\\')
    l = l:gsub('"','\\"')
    new = new..'"'..l..'\\n"'.."\n"
  end
  -- replace text
  editor:SetText(new)
end

return {
  exec = {
    name = "stringify to C",
    description = "stringifys the content for use in C",
    fn = cstringify,
  },
}
