## site.pp ##

# Define filebucket 'main':
filebucket { 'main':
    server => 'master',
      path => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

node default {
}

node r10k.example.com {
  include stdlib;
    file { ["/usr/local/mongodb/data", "/usr/local/mongodb"]:
    ensure => "directory",
    before => Class["::mongodb::server"],
  }

  class { '::mongodb::globals':
    version             => '2.2.7',
    server_package_name => 'mongodb-org-server-2.2.7.x86_64',
  }
  ->
  class { '::mongodb::server':
    auth    => true,
    user    => 'vagrant',
    group   => 'vagrant',
#  dbpath  => "/usr/local/mongodb/data/db",
  }

  mongodb::db { 'TestDB':
    user     => 'root',
    password => 'pwd',
    require  => Class["::mongodb::server"],
  }

  service { "iptables":
    ensure   => false,
  }
  ~>
  class { '::tomcat':
  }
  ~>
  tomcat::instance { 'default':
    running => true,
  }->
  tomcat::instance { 'A':
    running     => true,
    server_port => '8082',
    http_port   => '8011',
    ajp_port    => '8046',
  }
  include git;
  include ruby;
}
