local _fail = fail -- luacheck: ignore

local requests = {}
requests.__index = requests

setmetatable(requests, {
  __call = function(self, ...)
    return self.new(...)
  end
})

function requests.new(socket)
  local self = setmetatable({}, requests)
  
  
  
  return self
end

return requests