# man 5 autofs
# key [-options] location
define autofs::mount::map_entry (
  $path            = $name,
  $fstype          = undef,
  $strict          = false,
  $use_weight_only = true,
  $options         = [],
  $location        = undef,
) {
  if ! empty($options) { $options_real = join($options, ',') }
  if is_string($location) { $location_real = $location }
  elsif is_array($location) { $location_real = join($location, ' ') }
  else { fail("Valid types for location are String or Array of Strings") }

  notice("path=${path} options=-${options_real} location=${location_real}")
}

define autofs::mount::map_entries (
  $map_entry = $name,
  $filepath,
) {
  if is_string($map_entry) {
    $key = regsubst($map_entry,'^([^\s]*).*$', '\1')

    concat::fragment { "${filepath}_${key}":
      target  => $filepath,
      content => "${map_entry}\n",
    }
  }
}

define autofs::mount (
  $mount_point      = $name,
  $map_type         = 'file',
  $format           = 'sun',
  $map,
  $fstype           = undef,
  $options          = [],
  $D                = {},
  $strict           = false,
  $browse           = false,
  $nobind           = false,
  $symlink          = false,
  $random_multimount_selection = false,
  $use_weight_only  = false,
  $timeout          = undef,
  $negative_timeout = undef,
) {
  if ! (is_string($mount_point) and $mount_point == '/-') {
    validate_absolute_path($mount_point)
  }
  validate_re($map_type, '^file|program|exec|yp|nisplus|hesiod|ldap|ldaps|multi|dir$')
  validate_re($format, '^(sun|hesiod)$')
  validate_string($fstype)
  validate_bool($strict,$browse,$nobind,$symlink,$random_multimount_selection,$use_weight_only)
  if $timeout          { validate_integer($timeout,undef,0) }
  if $negative_timeout { validate_integer($negative-timeout,undef,0) }

  $name_safe = regsubst($name, '[/ ]', '_', G)
  $map_filepath = "/etc/auto.$name_safe"

  include autofs

  if is_string($map) {
    file { $map_filepath:
      ensure  => present,
      content => "${map}\n",
    }
  } elsif is_array($map) {
    concat { $map_filepath:
      ensure => present,
    }
    autofs::mount::map_entries { $map:
      filepath => $map_filepath,
    }
  } else {
    fail('Invalide type for $map')
  }

  if member(['dir',], $map_type) { $include = true }

  concat::fragment { "/etc/auto.master_${map_filepath}":
    target  => '/etc/auto.master',
    content => template("autofs/auto.master_mount.erb"),
  }
}
