 -- luacheck: ignore

local _fail = fail

local insert, concat = table.insert, table.concat
local lower, match = string.lower, string.match

local requests = {}
requests.__index = requests

setmetatable(requests, {
  __call = function(self, ...)
    return self.new(...)
  end
})


--[[

--default timeout: 60s
  local response, status, header = request--[[.get]] {
    url = "", -- or {scheme = "", userinfo = "", host = "", port = "", query = "" --[[or {}]], fragment = ""
    body = "", -- or {aa = 1}
    headers = {},
  }
--]]

requests._uri = function(url, encoder)
  local result = {}
  insert(result, assert(url.scheme, "URL scheme required"))
  insert(result, ":")
  local scheme = url.scheme
  if scheme == "http" or scheme == "https" then
    insert(result, "//")
  end
  if url.userinfo then
    insert(result, url.userinfo)
    insert(result, "@")
  end
  insert(result, assert(url.host, "URL host required"))
  if url.port then
    insert(result, ":")
    insert(result, url.port)
  end
  if url.path then
    local path = url.path
    if not match(path, "^/") then
      insert(result, "/")
    end
    insert(result, path)
  end
  if url.query then
    local query = url.query
    if type(query) == "table" then
      query = encoder(query)
    end
    if not match(query, "^%?") then
      insert(result, "?")
    end
    insert(result, query)
  end
  if url.fragment then
    local fragment = url.fragment
    if type(fragment) == "table" then
      fragment = encoder(fragment)
    end
    if not match(fragment, "^#") then
      insert(result, "#")
    end
    insert(result, fragment)
  end
  return concat(result)
end

requests._encoder = {
  ["ngx_lua"] = ngx.encode_args,
  ["lua-resty-http"] = ngx.encode_args,
}

requests._socket = {
  ["ngx_lua"] = function(data, encoder) -- https://github.com/leafo/lapis/blob/master/lapis/nginx/http.moon
    -- encode url
    local url = data.url
    if type(url) == "table" then
      url = requests._uri(url, encoder)
    end
    -- encode headers
    --  (pass)
    -- encode body
    local body = data.body
    if type(body) == "table" then
      body = encoder(body)
    end
    -- make request
    local result = ngx.location.capture("/proxy", {
      method = data.method,
      body = body,
      ctx = {
        headers = data.headers
      },
      vars = {
        _url = url
      }
    })
    return result.body, result.status, result.header
  end,
  ["lua-resty-http"] = function(data)
    -- encode url
    local url = data.url
    if type(url) == "table" then
      url = requests._uri(url, encoder)
    end
    -- encode headers
    --  (pass)
    -- encode body
    local body = data.body
    if type(body) == "table" then
      body = encoder(body)
    end
    local http = require("resty.http")
    local httpc = http.new()
    local result, err = httpc:request_uri(data.url, {
      method = data.method,
      body = data.body,
      headers = data.headers,
      keepalive_timeout = 60,
      keepalive_pool = 10
    })
    return result and (result.body, result.status, result.header) or (_fail, err)
  end,
  ["lua-resty-http"] = function(data)
    -- encode url
    local url = data.url
    if type(url) == "table" then
      url = requests._uri(url, encoder)
    end
    -- encode headers
    --  (pass)
    -- encode body
    local body = data.body
    if type(body) == "table" then
      body = encoder(body)
    end
    local http = require("resty.http")
    local httpc = http.new()
    local result, err = httpc:request_uri(data.url, {
      method = data.method,
      body = data.body,
      headers = data.headers,
      keepalive_timeout = 60,
      keepalive_pool = 10
    })
    return result and (result.body, result.status, result.header) or (_fail, err)
  end
}

function requests.new(socket)
  local self = setmetatable({}, requests)
  
  if not socket then
    self.socket = socket
  else
    self.socket = requests._detect()
  end
  
  if not self.socket then
    return _fail, "unable to detect socket"
  end

  return self
end

function requests._detect()
  if ngx then
    
  end
end



return requests