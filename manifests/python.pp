class webapp::python($ensure=present,
                     $owner="www-data",
                     $group="www-data",
                     $src_root="/usr/local/src",
                     $virtualenv_root="/usr/local/virtualenv",
                     $nginx_workers=1,
                     $monit_admin="",
                     $monit_interval=60,
                     $cache_dir='/var/cache/pip') {
#    class { "nginx":
#        ensure => $ensure,
#        workers => $nginx_workers
#    }

    class { "python::virtualenv":
        ensure => $ensure,
        owner => $owner,
        group => $group
    }

    class { "python::gunicorn":
        ensure => $ensure,
        owner => $owner,
        group => $group
    }

#    class { monit:
#        ensure => $ensure,
#        admin => $monit_admin,
#        interval => $monit_interval
#    }
}
