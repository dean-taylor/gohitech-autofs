class autofs (
  $mounts = {},
) inherits autofs::params {
  validate_hash($mounts)

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
  }
  concat::fragment { '/etc/auto.master_header':
    target  => '/etc/auto.master',
    content => template('autofs/auto.master.erb'),
    order   => '00',
  }

  if $mounts { create_resources(autofs::mount, $mounts) }
}
