local typedefs        = require "kong.db.schema.typedefs"
local sub             = string.sub
local get_phase       = ngx.get_phase
local param_len_limit = 2048


local function string_array_len(tbl)
  -- turn a string array into 1 long string
  if type(tbl) == "userdata" then
    return 0
  end
  if type(tbl) == "table" then
    local result = 0
    for _, v in pairs(tbl) do
      result = result+string_array_len(v)
    end
    return result
  elseif type(tbl) == "boolean" or type(tbl) == "number" or type(tbl) == "nil" or type(tbl) == "string" then
    return tostring(tbl):len()
  else
    return math.pow(2, 31)
  end
end

local function validate_issuer(conf)
  local phase = get_phase()
  if phase ~= "access" and phase ~= "content" then
    return true
  end
  if sub(conf.issuer, -1) ~= '/' then
    return false, "issuer must end with '/'!"
  end
  if string_array_len(conf.scopes_claim) > param_len_limit then
    return false, "scopes claim length must not be longer than "..param_len_limit.."!}"
  end
  if string_array_len(conf.scopes_required) > param_len_limit then
    return false, "scopes required length must not be longer than "..param_len_limit.."!}"
  end
  if string_array_len(conf.audience_claim) > param_len_limit then
    return false, "audience claim length must not be longer than "..param_len_limit.."!}"
  end
  if string_array_len(conf.audience_required) > param_len_limit then
    return false, "audience required length must not be longer than "..param_len_limit.."!}"
  end
  return true
end


return {
  name = "telstra-oidc-ccgf",
  fields = {
    { consumer  = typedefs.no_consumer    },
    { protocols = typedefs.protocols_http },
    { config    = {
        type             = "record",
        custom_validator = validate_issuer,
        fields           = {
          {
            issuer = typedefs.url {    --"/.well-known/openid-configuration"
              required = true,
            },
          },
          {
            scopes_claim = {   --Telstra: "roles"
              required = false,
              type     = "string",
              default  = "scopes",
            },
          },
          {
            scopes_required = {  --Telstra: ["API_GENERAL"]
              required = false,
              type     = "array",
              elements = {
                type = "string",
              },
            },
          },
          {
            audience_claim = {  --Telstra: "aud"
              required = false,
              type     = "string",
              default  = "aud",
            },
          },
          {
            audience_required = {   --Telstra: "https://npd-oidc"
              required = false,
              type     = "array",
              elements = {
                type = "string",
              },
            },
          },
          {
            ssl_verify = {  --Telstra: false
              required = false,
              type     = "boolean",
              default  = false,
            },
          },
          {
            timeout = typedefs.timeout {
              required = false,
              default  = 3600,
              between  = {0,10000}
            },
          },
        },
      },
    },
  },
}
