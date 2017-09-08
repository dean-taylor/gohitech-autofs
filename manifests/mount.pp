# man 5 autofs
# key [-options] location
define autofs::mount::map_entry (
  $key             = $name,
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

  notice("path=${key} options=-${options_real} location=${location_real}")
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
  } elsif is_hash($map_entry) {
    notice("Map entries of type Hash are not yet implemented.")
  } else { fail("Invalid type for $map_entry") }
}

define autofs::mount (
  $mount_point      = $name,	# <path>|/-|+
  $map_type         = undef,	# file|program|exec|yp|nisplus|hesiod|ldap|ldaps|multi|dir
  $format           = undef,	# sun|hesiod|amd
  $map,
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
  if ! (is_string($mount_point) and $mount_point =~ /^\/-|\+$/) {
    validate_absolute_path($mount_point)
  } else {
    validate_re($mount_point,'^/-|\+$')
  }
  if $map_type { validate_re($map_type, '^file|program|exec|yp|nisplus|hesiod|ldap|ldaps|multi|dir$') }
  # Validate 'map' field based on map format setting
  if $map_type == 'dir' { validate_absolute_path($map) }
  if $format { validate_re($format, '^sun|hesiod|amd$') }
  validate_string($fstype)
  validate_bool($strict,$browse,$nobind,$symlink,$random_multimount_selection,$use_weight_only)
  if $timeout          { validate_integer($timeout,undef,0) }
  if $negative_timeout { validate_integer($negative-timeout,undef,0) }

  $name_safe = regsubst($name, '[/ ]', '_', G)
  if $map_type == undef { $map_type_real = 'file' }
  else { $map_type_real = $map_type }
  if $format == undef {
    $format_real = $map_type ? {
      undef => 'sun',
      hesiod => 'hesiod',
      default => $map_type,
    }
  }

  include autofs

  if $mount_point == '+' {
    if $map_type == 'dir' {
      $map_filepath = $map

      # Created and owned by autofs daemon
      #file { "$map_filepath":
      #  ensure => present,
      #  group  => 'root',
      #  mode   => '0755',
      #  owner  => 'root',
      #  type   => directory,
      #}
    }
  } else {
    $map_filepath = "/etc/auto.$name_safe"

    if $map_type_real == 'file' and $format_real == 'sun' {
      if is_string($map) {
        file { $map_filepath:
          ensure  => present,
          content => "${map}\n",
        }
      } elsif is_array($map) {
        concat { $map_filepath:
          ensure => present,
          warn   => true,
        }
        autofs::mount::map_entries { $map:
          filepath => $map_filepath,
        }

      } else {
        fail('Invalide type for $map')
      }
    }
  }

#  if member(['dir',], $map_type) { $include = true }

  concat::fragment { "/etc/auto.master_${map_filepath}":
    target  => '/etc/auto.master',
    content => template("autofs/auto.master_mount.erb"),
  }
}
