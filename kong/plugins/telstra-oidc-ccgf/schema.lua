local typedefs  = require "kong.db.schema.typedefs"
local sub          = string.sub
local get_phase = ngx.get_phase


local function validate_issuer(conf)
  local phase = get_phase()
  if phase ~= "access" and phase ~= "content" then
    return true
  end
  if sub(conf.issuer, -1) ~= '/' then
    return false, "issuer must end with '/'!"
  end
  return true
end


return {
  name = "telstra-oidc-ccgf",
  fields = {
    { consumer  = typedefs.no_consumer    },
    { run_on    = typedefs.run_on_first   },
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
            timeout = {
              required = false,
              type     = "number",
              default  = 10000,
            },
          },
        },
      },
    },
  },
}
