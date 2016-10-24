# man autofs.conf
autofs::amd (
  $arch                  = undef,
  $karch                 = undef,
  $os                    = undef,
  $osver                 = undef,
  $full_os               = undef,
  $cluster               = undef,
  $vendor                = 'unknown',
  $auto_dir              = '/a',
  $map_type              = undef,	# file|nis|ldap|...
  $map_defaults          = '',
  $search_path           = undef,
  $dismount_interval     = 600,
  $autofs_use_lofs       = false,
  $nis_domain            = undef,
  $local_domain          = undef,
  $normalize_hostnames   = false,
  $domain_strip          = false,
  $normalize_slashes     = true,
  $selectors_in_defaults = false,	# selectors_on_default
  $ldap_base             = undef,
  $ldap_hostports        = undef,
  $hesiod_base           = undef,
  linux_ufs_mount_type   = undef,
) {
}
