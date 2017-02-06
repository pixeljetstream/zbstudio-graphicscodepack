-- Copyright (C) 2008-2017 Christoph Kubisch. All rights reserved.
---------------------------------------------------------

return {
  exec = {
    name = "Perforce revert",
    description = "does p4 revert",
    fn = function(fname,projectdir)
      local cmd = 'p4 revert "'..fname..'"'

      CommandLineRun(cmd,nil,true)
    end,
  },
}
