# == Resource: go_carbon::instance
# == Description: Defines a go-carbon service instance, including service management
#
define go_carbon::instance(
  $service_name                    = $title,
  $default_service                 = false,
  $ensure                          = 'present',
  $log_file                        = $go_carbon::params::log_file,
  $log_level                       = $go_carbon::params::log_level,
  $service_enable                  = $go_carbon::params::service_enable,
  $service_ensure                  = $go_carbon::params::service_ensure,
  $go_maxprocs                     = $go_carbon::params::go_maxprocs,
  $internal_graph_prefix           = $go_carbon::params::internal_graph_prefix,
  $internal_metrics_interval       = $go_carbon::params::internal_metrics_interval,
  $max_cpu                         = $go_carbon::params::max_cpu,
  $whisper_data_dir                = $go_carbon::params::whisper_data_dir,
  $whisper_schemas_file            = $go_carbon::params::whisper_schemas_file,
  $whisper_aggregation_file        = $go_carbon::params::whisper_aggregation_file,
  $whisper_workers                 = $go_carbon::params::whisper_workers,
  $whisper_max_updates_per_second  = $go_carbon::params::whisper_max_updates_per_second,
  $whisper_max_creates_per_second  = $go_carbon::params::whisper_max_creates_per_second,
  $whisper_enabled                 = $go_carbon::params::whisper_enabled,
  $cache_max_size                  = $go_carbon::params::cache_max_size,
  $cache_write_strategy            = $go_carbon::params::cache_write_strategy,
  $udp_listen                      = $go_carbon::params::udp_listen,
  $udp_log_incomplete              = $go_carbon::params::udp_log_incomplete,
  $udp_enabled                     = $go_carbon::params::udp_enabled,
  $udp_buffer_size                 = $go_carbon::params::udp_buffer_size,
  $tcp_listen                      = $go_carbon::params::tcp_listen,
  $tcp_enabled                     = $go_carbon::params::tcp_enabled,
  $tcp_buffer_size                 = $go_carbon::params::tcp_buffer_size,
  $pickle_listen                   = $go_carbon::params::pickle_listen,
  $pickle_max_message_size         = $go_carbon::params::pickle_max_message_size,
  $pickle_enabled                  = $go_carbon::params::pickle_enabled,
  $pickle_buffer_size              = $go_carbon::params::pickle_buffer_size,
  $carbonlink_listen               = $go_carbon::params::carbonlink_listen,
  $carbonlink_enabled              = $go_carbon::params::carbonlink_enabled,
  $carbonlink_read_timeout         = $go_carbon::params::carbonlink_read_timeout,
  $carbonserver_enabled            = $go_carbon::params::carbonserver_enabled,
  $carbonserver_listen             = $go_carbon::params::carbonserver_listen,
  $carbonserver_trigram_enabled    = $go_carbon::params::carbonserver_trigram_enabled,
  $dump_enabled                    = $go_carbon::params::dump_enabled,
  $dump_dir                        = $go_carbon::params::dump_dir,
  $pprof_listen                    = $go_carbon::params::pprof_listen,
  $pprof_enabled                   = $go_carbon::params::pprof_enabled,
  $grpc_listen                     = $go_carbon::params::grpc_listen,
  $grpc_enabled                    = $go_carbon::params::grpc_enabled,
)
{
  include go_carbon

  assert_type(Stdlib::Absolutepath, $log_file)
  unless $log_level =~ /^(debug|info|warn|warning|error)$/ {
    fail("Invalid log level '${log_level}'. Valid values: 'debug', 'info', 'warn', 'warning', 'error'.")
  }

  assert_type(String, $internal_graph_prefix)
  assert_type(String, $internal_metrics_interval)
  assert_type(Integer, $max_cpu)
  assert_type(Stdlib::Absolutepath, $whisper_data_dir)
  assert_type(Integer, $whisper_workers)
  assert_type(Integer, $whisper_max_updates_per_second)
  assert_type(Boolean, $whisper_enabled)
  assert_type(Integer, $cache_max_size)
  assert_type(String, $cache_write_strategy)
  assert_type(Integer, $go_maxprocs)
  assert_type(Boolean, $service_enable)

  unless $udp_listen =~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+$/ {
    fail("Invalid udp listen '${udp_listen}'. Must be {ip}:{port} or just :{port}")
  }
  assert_type(Boolean, $udp_log_incomplete)
  assert_type(Boolean, $udp_enabled)
  
  unless $tcp_listen =~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+$/ {
    fail("Invalid udp listen '${tcp_listen}'. Must be {ip}:{port} or just :{port}")
  }

  assert_type(Boolean, $tcp_enabled)
  unless $pickle_listen =~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+$/ {
    fail("Invalid pickle listen ${pickle_listen}. Must be {ip}:{port} or just :{port}")
  }

  assert_type(Integer, $pickle_max_message_size)
  assert_type(Boolean, $pickle_enabled)
  unless $carbonlink_listen =~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+$/ {
    fail("Invalid carbonlink listen ${carbonlink_listen}. Must be {ip}:{port} or just :{port}")
  }

  assert_type(Boolean, $carbonlink_enabled)
  assert_type(String, $carbonlink_read_timeout)
  unless $pprof_listen =~ /^((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+$/ {
    fail("Invalid pprof listen ${pprof_listen}. Must be {ip}:{port} or just :{port}")
  }

  assert_type(Boolean, $pprof_enabled)
  assert_type(Stdlib::Absolutepath, $whisper_schemas_file)
  assert_type(Stdlib::Absolutepath, $whisper_aggregation_file)

  if $default_service {
    $service_title = 'go-carbon'
  } else {
    $service_title = "go-carbon_${service_name}"
  }

  # Put the configuration files
  $executable = $go_carbon::executable
  $config_dir = $go_carbon::config_dir
  $user       = $go_carbon::user

  file {
    "${go_carbon::config_dir}/${service_title}.conf":
      ensure  => $ensure,
      content => template("${module_name}/go-carbon.conf.erb"),
      group   => $user,
      mode    => '0650',
      require => File[$go_carbon::config_dir],
  } ->
  go_carbon::service { $service_title: }

  Class[$module_name] ->
  File["${go_carbon::config_dir}/${service_title}.conf"]
}
