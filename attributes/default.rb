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
    default[:galaxy][:config]    = "#{galaxy[:path]}/universe_wsgi.ini"
    default[:galaxy][:port]      = "8080"

    default[:galaxy][:initfile]  = "/etc/init.d/galaxy" if( platform_version.to_f < 7.0)
end

# repository 
default[:galaxy][:repository]    = "https://bitbucket.org/galaxy/galaxy-dist/"

# about nginx site proxy settings
default[:galaxy][:nginxproxysetting] = false

# galaxy backend database ( default sqlite, mysql and postgresql )
default[:galaxy][:db][:type] = "sqlite"
# using mysql and postgresql
default[:galaxy][:db][:hostname] = "127.0.0.1"
default[:galaxy][:db][:admin][:username] = "root"
default[:galaxy][:db][:admin][:password] = "galaxydatabaserootpassword"
#
default[:galaxy][:db][:databasename] = "galaxy"
default[:galaxy][:db][:databaseusername] = "galaxy"
default[:galaxy][:db][:databasepassword] = "galaxydatabaseuserpassword"

