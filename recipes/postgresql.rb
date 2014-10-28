# galaxy database postgresql
include_recipe 'postgresql::client'
include_recipe 'database::postgresql'
# Externalize conection info in a ruby hash
postgresql_connection_info = {
  :host     => node[:galaxy][:db][:hostname],
  :username => node[:galaxy][:db][:admin][:username],
  :password => node[:galaxy][:db][:admin][:password]
}
# grant all privileges on all databases/tables from localhost
postgresql_database_user node[:galaxy][:db][:databaseusername] do
  connection postgresql_connection_info
  password node[:galaxy][:db][:databasepassword]
  encoding 'utf8'
  action :create
end
# Same create commands, connection info as an external hash
postgresql_database node[:galaxy][:db][:databasename] do
  connection postgresql_connection_info
  owner node[:galaxy][:db][:databaseusername]
  action :create
end


