# == Class: go_carbon
# == Description: Installs the go-carbon package and the shared configuration files
#
class go_carbon(
  $ensure                         = 'present',
  $package_name                   = $go_carbon::params::package_name,
  $version                        = $go_carbon::params::version,
  $download_deb_url               = "https://github.com/lomik/go-carbon/releases/download/v${version}/go-carbon_${version}_amd64.deb",
  $executable                     = $go_carbon::params::executable,
  $systemd_service_folder         = $go_carbon::params::systemd_service_folder,
  $config_dir                     = $go_carbon::params::config_dir,
  $user                           = $go_carbon::params::user,
  $group                          = $go_carbon::params::group,
  $manage_user                    = $go_carbon::params::manage_user,
  $storage_aggregations           = $go_carbon::params::storage_aggregations,
  $storage_schemas                = $go_carbon::params::storage_schemas,
  $download_package               = $go_carbon::params::download_package,
  $shell                          = $go_carbon::params::shell,
) inherits go_carbon::params {

  validate_re($::osfamily, '^(RedHat|Debian)', 'This module is only supported on RHEL/CentOS or Ubuntu')
  validate_re($::operatingsystemmajrelease, '^[67]|16.04|14.04|20.04$', 'This module is only supported on RHEL/CentOS 6/7 or Ubuntu 16.04/20.04')

  validate_string($package_name)
  validate_string($version)
  validate_absolute_path($executable)
  validate_absolute_path($config_dir)
  validate_absolute_path($systemd_service_folder)
  validate_string($user)
  validate_string($group)
  validate_array($storage_aggregations)
  validate_array($storage_schemas)

  include go_carbon::install
  include go_carbon::config

  Class['go_carbon::install'] ->
  Class['go_carbon::config']
}
