case platform
when "centos"

    # System account info
    default[:galaxy][:user]      = "galaxy"
    default[:galaxy][:group]     = "galaxy"
    default[:galaxy][:home]      = "/usr/local/galaxy"
    default[:galaxy][:shell]     = "/bin/bash"
    default[:galaxy][:password]  = nil

    # path to galaxy systems
    default[:galaxy][:reference] = "tip"
    default[:galaxy][:path]      = "#{galaxy[:home]}/galaxy-dist"
    default[:galaxy][:config]    = "#{galaxy[:path]}/universe_wsgi.ini"
    default[:galaxy][:port]      = "8080"

    default[:galaxy][:initfile]  = "/etc/init.d/galaxy" if( platform_version.to_f < 7.0)
end

#default[:galaxy][:repository]    = "https://bitbucket.org/galaxy/galaxy-dist/"
default[:galaxy][:repository]    = "https://bitbucket.org/galaxy/galaxy-dist/commits/tag/release_2014.08.11"

# about nginx site proxy settings
default[:galaxy][:nginxproxysetting] = false
