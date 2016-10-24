# man autofs_ldap_auth.conf
autofs::ldap::auth (
  $usetls = true,	# "yes"|"no"
  $tlsrequired = true,	# "yes"|"no"
  $authrequired = true,	# "yes"|"no"|"autodetect"|"simple"
  $authtype     = undef,	# "GSSAPI"|"LOGIN"|"PLAIN"|"ANONYMOUS"|"DIGEST-MD5"|"EXTERNAL"
  $external_cert = undef,
  $external_key  = undef,
  $user          = undef,
  $secret        = undef,
  $encoded_secret = undef,	# base64 encoded password
  $clientprinc    = undef,	# GSSAPI client principal; default: autof‐sclient/<fqdn>@<REALM>
  $credentialcache = undef,	# external credential cache path
) inherits autofs::params {
  if $authtype == "EXTERNAL" { validate_path($external_cert,$external_key) }
  if $user { validate_string($user) }
  if $secret { validate_string($secret) }
  if $encoded_secret
  if $authtype == "GSSAPI" {
    if $clientprinc { validate_re($clientprinc,'^[a-z-]+.*/[a-z.-]+@[A-Z.]+$') }
    if $credentialcache { validate_string($credentialcache) }
  }
}
