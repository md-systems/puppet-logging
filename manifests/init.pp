# == Class: logging
#
# === Examples
#
#  class { 'logging': }
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
class logging (
  $syslog,
  $lumberjack,
  $ssl_ca_path = '/etc/ssl/certs/logstash.crt'
) {
  file {'syslog_logstash':
    path   => '/etc/rsyslog.d/logstash.conf',
    content => template('logging/syslog/logstash.erb'),
  }

  service { 'rsyslog': }

  File['syslog_logstash'] ~> Service['rsyslog']

  file {'logstash_crt':
    path   => $ssl_ca_path,
    source => 'puppet:///modules/logging/logstash.crt',
  }

  if $::architecture != 'armv6l' {
    class { 'lumberjack':
      servers       => $lumberjack,
      ssl_ca_path   => $ssl_ca_path,
      log_to_syslog => true,
    }

    # @todo Remove duplication of $access_log_pipe & $access_log_format on vhosts.
    lumberjack::file { 'stdin':
      paths    => ['-'],
      fields   => { 'type' => 'stdin' },
    }
  }
}
