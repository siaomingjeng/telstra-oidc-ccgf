# telstra-oidc-ccgf
This is Kong custom plugin for Client Credentials Grant Flow of OpenID-Connect.

This plugin validates the signature, audience and scopes in the access token or id token.

Parameters:
* issuer: string of url. Last charactor must be '/', as '/.well-known/openid-configuration' will be added.
* scopes_claim: string. The length must not be longer than 2KB.
* scopes_required: array of string elements. Total length must not be longer than 2KB.
* audience_claim: string. The length must not be longer than 2KB.
* audience_required: array of string elements. Total length must not be longer than 2KB.
* ssl_verify: boolen
* timeout: number. Value must between 0 and 10000
