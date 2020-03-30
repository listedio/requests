local _fail = fail -- luacheck: ignore

local request = {}
request.__index = request

setmetatable(request, {
  __call = function(self, ...)
    return self.new(...)
  end
})

function request.new(options)
  local self = setmetatable({}, request)
  
  
  
  return self
end

return request