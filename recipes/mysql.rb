# galaxy database mysql
include_recipe 'mysql::client'
include_recipe 'database::mysql'
# Externalize conection info in a ruby hash
mysql_connection_info = {
  :host     => node[:galaxy][:db][:hostname],
  :username => node[:galaxy][:db][:admin][:username],
  :password => node[:galaxy][:db][:admin][:password]
}
# Same create commands, connection info as an external hash
mysql_database node[:galaxy][:db][:databasename] do
  connection mysql_connection_info
  action :create
end


# grant all privileges on all databases/tables from localhost
mysql_database_user node[:galaxy][:db][:databaseusername] do
  connection mysql_connection_info
  database_name node[:galaxy][:db][:databasename]
  privileges    [:all]
  password node[:galaxy][:db][:databasepassword]
  action :grant
end
