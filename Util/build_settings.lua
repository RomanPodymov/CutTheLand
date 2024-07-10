local root = os.getenv('GITHUB_WORKSPACE') or os.getenv('WORKSPACE') or ".."

local params = { 
   platform='macOS', 
   appName='Cut_The_Land', 
   appVersion='1.0.0', 
   dstPath=root .. '/Build',
   projectPath=root .. '/Project',
   type='developer'
} 

return params