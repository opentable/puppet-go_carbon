# == Class: go_carbon::params
# == Description: Default parameters
class go_carbon::params {
  $package_name                       = 'go-carbon'
  $version                            = $::osfamily ? {
    'RedHat' => '0.7-1.el6',
    'Debian' => '0.7.1',
  }
  $executable                         = $::osfamily ? {
    'RedHat' => '/usr/local/bin/go-carbon',
    'Debian' => '/usr/sbin/go-carbon',
  }
  $config_dir                         = '/etc/go-carbon'
  $systemd_service_folder             = '/lib/systemd/system'
  $service_enable                     = true
  $service_ensure                     = running
  $go_maxprocs                        = 2
  $storage_schemas = [
    {
      'default_1min_for_7day' => {
        pattern => '.*',
        retentions => '60s:7d'
      }
    }
  ]
  $storage_aggregations = [
    {
      'default_average' => {
        pattern => '.*',
        xFilesFactor => '0.3',
        aggregationMethod => 'average'
      }
    }
  ]
  # Run as user. Works only in daemon mode
  $user                               = 'gocarbon'
  $group                              = 'gocarbon'
  # Prefix for store all internal go-carbon graphs. Supported macroses: {host}
  $internal_graph_prefix              = 'carbon.agents.{host}.'
  # Interval of storing internal metrics. Like CARBON_METRIC_INTERVAL
  $internal_metrics_interval          = '1m0s'
  # Increase for configuration with multi persisters
  $max_cpu                            = 1

  $whisper_data_dir                   = '/var/lib/graphite/whisper'
  # http://graphite.readthedocs.org/en/latest/config-carbon.html#storage-schemas-conf. Required
  $whisper_schemas_file               = "${config_dir}/storage-schemas.conf"
  # http://graphite.readthedocs.org/en/latest/config-carbon.html#storage-aggregation-conf. Optional
  $whisper_aggregation_file           = "${config_dir}/storage-aggregations.conf"
  # Workers count. Metrics sharded by "crc32(metricName) % workers"
  $whisper_workers                    = 1
  # Limits the number of whisper update_many() calls per second. 0 - no limit
  $whisper_max_updates_per_second     = 0
  $whisper_max_creates_per_second     = 500
  $whisper_enabled                    = true

  # Limit of in-memory stored points (not metrics)
  $cache_max_size                     = 1000000
  # Capacity of queue between receivers and cache
  # Strategy to persist metrics. Values: "max","sorted","noop"
  #   "max" - write metrics with most unwritten datapoints first
  #   "sorted" - sort by timestamp of first unwritten datapoint.
  #   "noop" - pick metrics to write in unspecified order,
  #            requires least CPU and improves cache responsiveness
  $cache_write_strategy               = 'max'

  $udp_listen                         = ':2003'
  # Enable optional logging of incomplete messages (chunked by MTU)
  $udp_log_incomplete                 = false
  $udp_enabled                        = true
  # Optional internal queue between receiver and cache
  $udp_buffer_size                    = 0

  $tcp_listen                         = ':2003'
  $tcp_enabled                        = true
  # Optional internal queue between receiver and cache
  $tcp_buffer_size                    = 0

  $pickle_listen                      = ':2004'
  # Limit message size for prevent memory overflow
  $pickle_max_message_size            = 67108864
  $pickle_enabled                     = true
  # Optional internal queue between receiver and cache
  $pickle_buffer_size                 = 0


  $carbonlink_listen                  = '127.0.0.1:7002'
  $carbonlink_enabled                 = true
  # Close inactive connections after "read-timeout"
  $carbonlink_read_timeout            = '30s'

  $pprof_listen                       = '127.0.0.1:7007'
  $pprof_enabled                      = false
  $download_package                   = false
  $shell                              = $::osfamily ? {
    'RedHat' => '/sbin/nologin',
    'Debian' => '/usr/sbin/nologin',
  }

  $log_file                           = '/var/log/go-carbon/go-carbon.log'
  # Logging error level. Valid values: "debug", "info", "warn", "warning", "error"
  $log_level                          = 'info'
}
