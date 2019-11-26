# telstra-oidc-ccgf
This is Kong custom plugin for Client Credentials Grant Flow of OpenID-Connect.

This plugin validates the signature, audience and scopes in the access token or id token.

Parameters:
* issuer: string of url
* scopes_claim: string
* scopes_required: array of string elements
* audience_claim: string
* audience_required: array of string elements
* ssl_verify: boolen
* timeout: number
