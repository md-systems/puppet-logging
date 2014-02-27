# == Class: logging::server
#
# === Examples
#
#  class { 'logging::server': }
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
class logging::server {
  class { 'elasticsearch': }
  class { 'kibana':
    manage_ruby => true,
  }

  class { 'logstash':
    java_install => true,
    installpath => '/opt/logstash',
  }

  file {'logstash_syslog':
    path   => '/etc/logstash/agent/config/syslog',
    source => 'puppet:///modules/logging/logstash/syslog',
  }
  file {'logstash_lumberjack':
    path   => '/etc/logstash/agent/config/lumberjack',
    source => 'puppet:///modules/logging/logstash/lumberjack',
  }
  file {'logstash_output':
    path   => '/etc/logstash/agent/config/output',
    source => 'puppet:///modules/logging/logstash/output',
  }

  Class['elasticsearch'] -> Class['logstash'] -> Class['kibana']
  File['logstash_syslog'] -> File['logstash_lumberjack'] -> File['logstash_output'] ~> Service['logstash']
}
