class autofs (
  $append_options   = true,     # yes
  $browse_mode      = true,     # yes
  $force_standard_program_map_env = 1024,
  $logging          = 'none',   # none|verbose|debug
  $mount_nfs_default_protocol = 3,
  $mount_wait       = undef,
  $mounts           = {},
  $negative_timeout = 60,
  $timeout          = 300,
  $umount_wait      = undef,
) inherits autofs::params {
  validate_bool($append_options,$browse_mode)
  validate_integer($force_standard_program_map_env)
  validate_re($logging,'^none|verbose|debug$')
  validate_integer($mount_nfs_default_protocol,4,2)
  if $mount_wait { validate_integer($mount_wait) }
  validate_hash($mounts)
  validate_integer($negative_timeout)
  validate_integer($timeout)
  if $umount_wait { validate_integer($umount_wait) }

  package { 'autofs':
    ensure => installed,
  }

  service { 'autofs':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package['autofs'],
  }

  concat { '/etc/auto.master':
    ensure         => present,
    ensure_newline => true,
    warn           => true,
  }

  if $mounts { create_resources(autofs::mount, $mounts) }
}

# == Class: autofs
#
# Full description of class autofs here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { autofs:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Dean Taylor <dean@gohitech.net>
#
# === Copyright
#
# Copyright 2016 Dean Taylor, unless otherwise noted.
#

