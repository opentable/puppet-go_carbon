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

  validate_absolute_path($log_file)
  validate_re($log_level, [ '^debug', '^info', '^warn', '^warning', '^error' ],
    "Invalid log level ${log_level}, Valid values: 'debug', 'info', 'warn', 'warning', 'error'")
  validate_string($internal_graph_prefix)
  validate_string($internal_metrics_interval)
  validate_integer($max_cpu)
  validate_absolute_path($whisper_data_dir)
  validate_integer($whisper_workers)
  validate_integer($whisper_max_updates_per_second)
  validate_bool($whisper_enabled)
  validate_integer($cache_max_size)
  validate_string($cache_write_strategy)
  validate_integer($go_maxprocs)
  validate_bool($service_enable)

  validate_re($udp_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid udp listen ${udp_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($udp_log_incomplete)
  validate_bool($udp_enabled)
  
  validate_re($tcp_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid tcp listen ${tcp_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($tcp_enabled)
  
  validate_re($pickle_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid pickle listen ${pickle_listen}. Must be {ip}:{port} or just :{port}")

  validate_integer($pickle_max_message_size)
  validate_bool($pickle_enabled)
  
  validate_re($carbonlink_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid carbonlink listen ${carbonlink_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($carbonlink_enabled)
  validate_string($carbonlink_read_timeout)
  
  validate_re($pprof_listen, '((?:[0-9]{1,3}\.){3}[0-9]{1,3})?:\d+',
    "Invalid pprof listen ${pprof_listen}. Must be {ip}:{port} or just :{port}")

  validate_bool($pprof_enabled)
  validate_absolute_path($whisper_schemas_file)
  validate_absolute_path($whisper_aggregation_file)

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
