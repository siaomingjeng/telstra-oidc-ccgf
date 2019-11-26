local BasePlugin   = require "kong.plugins.base_plugin"
local openidc      = require "resty.openidc"
local cjson        = require "cjson"
local getn         = table.getn
local ERR          = ngx.ERR
local DEBUG        = ngx.DEBUG


local function log(level, ...)
  return ngx.log(level, "[telstra-openid-ccgf] ", ...)
end

local function table_to_string(tbl)
  if type(tbl) == "table" then
    local result = ""
    for k, v in pairs(tbl) do
      result = result.."\""..k.."\""..":"..table_to_string(v)..","
    end
    if result ~= "" then
      result = result:sub(1, result:len()-1)
    end
    return "{"..result.."}"
  elseif type(tbl) == "boolean" or type(tbl) == "number" or type(tbl) == "nil" or type(tbl) == "string" then
    return "\""..tostring(tbl).."\""
  else
    return "<"..type(tbl)..">"
  end
end

local function forbidden(err)
  log(ERR, err)
  return kong.response.exit(403, { message = err })
end

local function verify_claims(claims, searches)
  claims = type(claims) == "table" and claims or {claims}
  searches = type(searches) == "table" and searches or {searches}
  if getn(searches) == 0 then
    log(DEBUG, "No searches provided, no needed to verify!")
    return true
  end
  if getn(claims) == 0 then
    log(ERR, "No claims provided to be searched from!")
    return false
  end
  local num_found = 0
  for _, search in pairs(searches) do
    for _, claim in pairs(claims) do
      if  claim == search then
        num_found = num_found + 1
        break
      end
    end
  end
  if getn(searches) == num_found then
    return true
  else
    return false
  end
end

local OICHandler = BasePlugin:extend()


function OICHandler:new()
  OICHandler.super.new(self, "OIDC - Client Credwntials Grant Flow")
end


function OICHandler:access(conf)
  OICHandler.super.access(self)

  -- Verify signature
  local opts={}
  opts.ssl_verify = conf.ssl_verify and 'yes' or 'no'   -- Need 'no' or 'yes' in library of lua-resty-openidc.
  opts.discovery = conf.issuer..".well-known/openid-configuration"  -- opts.discovery ischanged to table after successful request call.
  --log(ERR, "Start Time: ",socket.gettime())
  local jwt_json, err, access_token = openidc.bearer_jwt_verify(opts)
  log(DEBUG, "jwt_json: ", cjson.encode(jwt_json), ", err: ", err, ' ', type(err), ", access_token: ", access_token)
  if err or not jwt_json then
    return forbidden(err)
  end

  -- Verify 'array: scopes_required'
  local scopes_required = conf.scopes_required
  if scopes_required then
    log(DEBUG, "verifying required scopes")
    local scopes_claim = conf.scopes_claim or { "scopes" }
    local scopes_found = jwt_json[scopes_claim]
    log(DEBUG, "scopes_found: ", table_to_string(scopes_found), ' ', type(scopes_found))
    if not verify_claims(scopes_found,scopes_required) then
      err = 'Scope not validated!'
      return forbidden(err)
    end
  end
  -- Verify 'array: audience_required'
  local audience_required = conf.audience_required
  if audience_required then
    log(DEBUG, "verifying required audience")
    local audience_claim = conf.audience_claim or { "aud" }
    local audience_found = jwt_json[audience_claim]
    log(DEBUG, "audience_found: ", table_to_string(audience_found),' ', type(audience_found))
    if not verify_claims(audience_found,audience_required) then
      err = 'Audience not validated!'
      return forbidden(err)
    end
  end
end


OICHandler.PRIORITY = 999
OICHandler.VERSION  = 1.0
return OICHandler