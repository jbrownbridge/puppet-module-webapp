define webapp::python::instance($domain,
                                $ensure=present,
                                $owner = $webapp::python::owner,
                                $group = $webapp::python::group,
                                $git_repo=undef,
                                $git_rev='master',
                                $aliases=[],
                                $mediaroot="",
                                $mediaprefix="",
                                $wsgi_module="",
                                $django=false,
                                $django_settings="",
                                $requirements=false,
                                $cache_dir=$webapp::python::cache_dir,
                                $workers=1,
                                $timeout_seconds=30,
                                $monit_memory_limit=300,
                                $monit_cpu_limit=50) {

    $virtualenv = "${webapp::python::virtualenv_root}/$name"
    $src = "${webapp::python::src_root}/$name"

    $pidfile = "${python::gunicorn::rundir}/${name}.pid"
    $socket = "${python::gunicorn::rundir}/${name}.sock"

    if $git_repo {
        vcsrepo { $src:
            force => true,
            ensure => $ensure ? {
                'absent' => 'absent',
                default => 'latest',
            },
            owner => $owner,
            group => $group,
            provider => git,
            source => $git_repo,
            revision => $git_rev,
            before => Python::Virtualenv::Instance[$virtualenv],
        }
    }

#    nginx::site { $name:
#        ensure => $ensure,
#        domain => $domain,
#        aliases => $aliases,
#        root => "/var/www/$name",
#        mediaroot => $mediaroot,
#        mediaprefix => $mediaprefix,
#        upstreams => ["unix:${socket}"],
#        owner => $owner,
#        group => $group,
#        require => Python::Gunicorn::Instance[$name],
#    }

    python::virtualenv::instance { $virtualenv:
        ensure => $ensure,
        owner => $owner,
        group => $group,
        requirements => $requirements ? {
            true => "$src/requirements.txt",
            false => undef,
            default => "$src/$requirements",
        },
        cache_dir => $cache_dir,
        require => Vcsrepo[$src],
    }

#    python::gunicorn::instance { $name:
#        ensure => $ensure,
#        virtualenv => $virtualenv,
#        src => $src,
#        wsgi_module => $wsgi_module,
#        django => $django,
#        django_settings => $django_settings,
#        workers => $workers,
#        timeout_seconds => $timeout_seconds,
#        require => $ensure ? {
#            'present' => Python::Virtualenv::Instance[$virtualenv],
#            default => undef,
#        },
#        before => $ensure ? {
#            'absent' => Python::Virtualenv::Instance[$virtualenv],
#            default => undef,
#        },
#    }
#
#    $reload = "/etc/init.d/gunicorn-$name reload"

#    monit::monitor { "gunicorn-$name":
#        ensure => $ensure,
#        pidfile => $pidfile,
#        socket => $socket,
#        checks => ["if totalmem > $monit_memory_limit MB for 2 cycles then exec \"$reload\"",
#                  "if totalmem > $monit_memory_limit MB for 3 cycles then restart",
#                  "if cpu > ${monit_cpu_limit}% for 2 cycles then alert"],
#        require => $ensure ? {
#            'present' => Python::Gunicorn::Instance[$name],
#            default => undef,
#        },
#        before => $ensure ? {
#            'absent' => Python::Gunicorn::Instance[$name],
#            default => undef,
#        },
#    }
}
