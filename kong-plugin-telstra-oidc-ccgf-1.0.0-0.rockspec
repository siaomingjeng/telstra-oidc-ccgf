package = "kong-plugin-telstra-oidc-ccgf"
version = "1.0.0-0"

source = {
  url = "https://github.com/siaomingjeng/telstra-oidc-ccgf.git",
}

description = {
  summary    = "Kong OpenID Connect Plugin",
  detailed   = [[
    Kong OpenID Connect 1.3 plugin for integrating with 3rd party identity providers.
    TBC.
  ]],
  homepage   = "https://github.com/siaomingjeng/telstra-oidc-ccgf.git",
  maintainer = "Raymond Zheng <raymond.zheng@health.telstra.com>",
}

dependencies = {
  "lua >= 5.1",
  "lua-resty-openidc >= 1.7.2",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.telstra-oidc-ccgf.handler"]                            = "kong/plugins/telstra-oidc-ccgf/handler.lua",
    ["kong.plugins.telstra-oidc-ccgf.schema"]                             = "kong/plugins/telstra-oidc-ccgf/schema.lua",
  },
}
