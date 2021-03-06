case platform
when "centos"

    # System account info
    default[:galaxy][:user]      = "galaxy"
    default[:galaxy][:group]     = "galaxy"
    default[:galaxy][:home]      = "/usr/local/galaxy"
    default[:galaxy][:shell]     = "/bin/bash"
    default[:galaxy][:password]  = nil

    # path to galaxy systems
    # if you want to use latest version , set reference to 'tip'
    default[:galaxy][:reference] = "release_2014.08.11"
    default[:galaxy][:path]      = "#{galaxy[:home]}/galaxy-dist"

    # normal service
    default[:galaxy][:config]    = "universe_wsgi.ini"
    default[:galaxy][:kicker]    = "run.sh"
    default[:galaxy][:pid]       = "#{galaxy[:path]}/paster.pid"
    default[:galaxy][:log]       = "#{galaxy[:path]}/paster.log"
    default[:galaxy][:port]      = "8080"
    default[:galaxy][:admin]     = "galaxy-admin"
    default[:galaxy][:domain]    = "foo.baa"
    # with tool shed, for the galaxy-admin's settins
    default[:galaxy][:shedtools_path]       = "#{galaxy[:home]}/shed_tool"
    default[:galaxy][:shedtools_config]     = "#{galaxy[:path]}/shed_tool_conf.xml"

    default[:galaxy][:initfile]  = "/etc/init.d/galaxy" if( platform_version.to_f < 7.0)

end

# repository 
default[:galaxy][:repository]    = "https://bitbucket.org/galaxy/galaxy-dist/"

# about nginx site proxy settings
default[:galaxy][:nginxproxysetting] = false
