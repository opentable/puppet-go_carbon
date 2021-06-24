# == Resource: go_carbon::service
# == Description: Installs an upstart / systemd service definition.
define go_carbon::service(
  $service_name = $title,
  $service_ensure = 'running',
  $service_enable = true)
{

  exec { "${service_name}-service-reload":
    path        => ['/bin','/usr/bin','/usr/sbin/'],
    command     => "service ${service_name} reload",
    subscribe   => [
      File[$go_carbon::whisper_schemas_file],
      File[$go_carbon::whisper_aggregation_file]
    ],
    refreshonly => true,
    onlyif      => "/usr/bin/go-carbon -config ${go_carbon::config_dir}/${service_name}.conf -check-config=true"
  }

  case $::operatingsystemmajrelease {
    '6': {
      # Put the upstart config file
      file { "/etc/init/${service_name}.conf":
        ensure  => $go_carbon::ensure,
        content => template("${module_name}/upstart.go-carbon.conf.erb")
      }

      # Instantiate the go-carbon service
      service {
        "${service_name}":
          ensure     => $service_ensure,
          hasrestart => false,
          stop       => "/sbin/initctl stop ${service_name}",
          start      => "/sbin/initctl start ${service_name}",
          status     => "/sbin/initctl status ${service_name} | grep -q -- '/running'",
          subscribe  => [File["/etc/init/${service_name}.conf"],
                            File["${go_carbon::config_dir}/${service_name}.conf"]]
      }
    }

    '7', '16.04': {
      file { "${::go_carbon::systemd_service_folder}/${service_name}.service":
        ensure  => $go_carbon::ensure,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/systemd.go-carbon.conf.erb")
      } ~>
      Exec['systemctl-daemon-reload']
      service { "${service_name}":
        ensure    => $service_ensure,
        enable    => $service_enable,
        provider  => systemd,
        subscribe =>
        [
          File["${go_carbon::systemd_service_folder}/${service_name}.service"],
          File["${go_carbon::config_dir}/${service_name}.conf"]
        ]
      }
    }

    '14.04': {
      file { "/etc/init.d/${service_name}":
        ensure  => $go_carbon::ensure,
        mode    => '0744',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/init.go-carbon.erb")
      } ~>

      service { "${service_name}":
        ensure    => $service_ensure,
        enable    => $service_enable,
        subscribe =>
        [
          File["/etc/init.d/${service_name}"],
          File["${go_carbon::config_dir}/${service_name}.conf"]
        ]
      }
    }

    default: {
      fail("Unable to install a go-carbon service on OS version ${::operatingsystemmajrelease}.")
    }
  }
}
