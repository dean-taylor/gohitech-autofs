autofs::ldap (
  $timeout            = 8,
  $network_timeout    = 8,
  $uri                = [],
  $search_base        = [],
  $map_object_class,
  $entry_object_class,
  $map_attribute,
  $entry_attribute,
  $value_attribute,
  $auth_conf_file     = undef,
) inherits autofs::params {
  validate_integer($timeout)
  validate_integer($network_timeout)
  validate_string($map_object_class,$entry_object_class,$map_attribute)
}
