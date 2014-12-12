#
# Cookbook Name:: galaxy
# Recipe:: default
#
# Copyright 2014, RIKEN ACCC
#
# All rights reserved - Do Not Redistribute
#
user "galaxy" do
    username node[:galaxy][:user]
    home     node[:galaxy][:home]
    shell    node[:galaxy][:shell]
    password node[:galaxy][:password]

    supports :manage_home => true
    action   :create
end
# set directory owner and permission mainly for shared file system
directory node[:galaxy][:home] do
    owner node[:galaxy][:user]
    group      node[:galaxy][:group]
    mode '0755'
end

include_recipe "python"

#include_recipe "mercurial"
#mercurial node[:galaxy][:path] do
#    repository node[:galaxy][:repository]
#    owner      node[:galaxy][:user]
#    group      node[:galaxy][:group]
#    reference  node[:galaxy][:reference]
#
#    action     :clone
#end

# galaxy main directory
directory node[:galaxy][:path] do
    owner node[:galaxy][:user]
    group      node[:galaxy][:group]
    mode '0755'
end

# galaxy for sed tools directory
directory node[:galaxy][:shedtools_path] do
    owner node[:galaxy][:user]
    group      node[:galaxy][:group]
    mode '0755'

    action   :create
end

include_recipe "python"

# virtualenv related variables
virtualenv_home  = node[:galaxy][:path]+"/.venv"
user_name        = node[:galaxy][:user]

# install
python_pip "virtualenv" do
    action :install
end
python_virtualenv virtualenv_home do
  action :create
  owner node[:galaxy][:user]
  group node[:galaxy][:group]
end

case node[:galaxy][:cluster][:type]
when 'sge'
  python_pip "drmaa" do
    action :install
    user node[:galaxy][:user]
    group node[:galaxy][:group]
    virtualenv virtualenv_home
  end
end

#
sourcecodefile=node[:galaxy][:reference]+".tar.bz2"
remote_file node[:galaxy][:home]+"/"+sourcecodefile do
    source "https://bitbucket.org/galaxy/galaxy-dist/get/"+sourcecodefile
    action :create_if_missing
end

# backend database
galaxy_config_file = node[:galaxy][:path]+"/"+node[:galaxy][:config]
bash "extract file" do
    code   "tar jxvf #{node[:galaxy][:home]}/#{sourcecodefile} -C #{node[:galaxy][:path]} --strip=1"
    action :run
    user node[:galaxy][:user]
    group node[:galaxy][:group]
    not_if { ::File.exist?(galaxy_config_file) }
end

database_setting = node[:galaxy][:db][:databaseusername]+":"+node[:galaxy][:db][:databasepassword]+"@"+node[:galaxy][:db][:hostname]+"/"+node[:galaxy][:db][:databasename]
database_connection = ""
case node[:galaxy][:db][:type]
  when 'sqlite'
    include_recipe 'galaxy::sqlite'
  when 'mysql'
    include_recipe 'galaxy::mysql'
    database_connection = "mysql://"+database_setting
  when 'postgresql'
    include_recipe 'galaxy::postgresql'
    database_connection = "postgresql://"+database_setting
end
# create
bash "build galaxy config" do
  code   "cd #{node[:galaxy][:path]} ; python ./scripts/check_python.py ; ./scripts/common_startup.sh"
  action :run
  user node[:galaxy][:user]
  group node[:galaxy][:group]
  not_if { ::File.exist?(galaxy_config_file) }
end
# database connection setting update
case node[:galaxy][:db][:type]
  when 'mysql', 'postgresql'
    database_connection_line = /^database_connection/
    ruby_block "insert database_connection line" do
      block do
        file = Chef::Util::FileEdit.new(galaxy_config_file)
        file.insert_line_after_match(/^#database_connection/, "database_connection = "+database_connection)
        file.write_file
      end
      not_if { ::File.exist?(galaxy_config_file) && ::File.readlines(galaxy_config_file).grep(database_connection_line).any? }
    end
    ruby_block "replace database_connection line" do
      block do
        file = Chef::Util::FileEdit.new(galaxy_config_file)
        file.search_file_replace_line(database_connection_line, "database_connection = "+database_connection)
        file.write_file
      end
      only_if { ::File.exist?(galaxy_config_file) && ::File.readlines(galaxy_config_file).grep(database_connection_line).any? }
    end
end
# setup dataase
bash "setup galaxy database" do
  code   "cd #{node[:galaxy][:path]} ; ./create_db.sh"
  action :run
  user node[:galaxy][:user]
  group node[:galaxy][:group]
  environment 'HOME' => node[:galaxy][:home]
end
#
# target_file: file which you want manipulate
# target_line_prefix: target line prefix (eg. /^#admin_users/ )
# desired_line_prefix: desired line prefix (eg. /^admin_users/ )
# desired_line: desired line line (eg. "admin_users = admin@example.com" )
def insert_or_replace_line(target_file, target_line_prefix,desired_line_prefix, desired_line)
  if desired_line != nil
    ruby_block "insert line" do
      block do
        file = Chef::Util::FileEdit.new(target_file)
        file.insert_line_after_match(target_line_prefix, desired_line)
        file.write_file
      end
      not_if { ::File.exist?(target_file) && ::File.readlines(target_file).grep(desired_line_prefix).any? }
    end
    ruby_block "replace line" do
      block do
        file = Chef::Util::FileEdit.new(target_file)
        file.search_file_replace_line(desired_line_prefix, desired_line)
        file.write_file
      end
      only_if { ::File.exist?(target_file) && ::File.readlines(target_file).grep(desired_line_prefix).any? }
    end
  end
end

# setup admin
admin_users = node[:galaxy][:admin_users]
if admin_users != nil
  insert_or_replace_line(galaxy_config_file, /^#admin_users/, /^admin_users/, "admin_users = "+admin_users)
end
# setup master_api_key
master_api_key = node[:galaxy][:master_api_key]
if master_api_key != nil
  insert_or_replace_line(galaxy_config_file, /^#master_api_key/, /^master_api_key/, "master_api_key = "+master_api_key)
end
# setup tool_dependency_dir
tool_dependency_dir = node[:galaxy][:tool_dependency_dir]
if tool_dependency_dir != nil
  insert_or_replace_line(galaxy_config_file, /^#tool_dependency_dir/, /^tool_dependency_dir/, "tool_dependency_dir = "+tool_dependency_dir)
end

# setup compute cluster (job scheduler)
case node[:galaxy][:cluster][:type]
when 'sge'
  job_config_file_line = /^job_config_file/
  job_config_file = node[:galasy][:cluster][:jobconfigfile]
  ruby_block "insert job_config_file line" do
    block do
      file = Chef::Util::FileEdit.new(galaxy_config_file)
      file.insert_line_after_match(/^#job_config_file/, "job_config_file = "+job_config_file)
      file.write_file
    end
    not_if { ::File.exist?(galaxy_config_file) && ::File.readlines(galaxy_config_file).grep(job_config_file_line).any? }
  end
  ruby_block "replace job_config_file line" do
    block do
      file = Chef::Util::FileEdit.new(galaxy_config_file)
      file.search_file_replace_line(job_config_file_line, "job_config_file = "+job_config_file)
      file.write_file
    end
    only_if { ::File.exist?(galaxy_config_file) && ::File.readlines(galaxy_config_file).grep(job_config_file_line).any? }
  end
  # job_conf.xml
  template node[:galaxy][:path]+"/"+node[:galasy][:cluster][:jobconfigfile] do
    owner      node[:galaxy][:user]
    group      node[:galaxy][:group]
    mode       "0644"
    source     "job_conf.xml.erb"
    action     :create
  end
end

template "/etc/init.d/galaxy" do
    owner      "root"
    group      "root"
    mode       "0755"
    source     "galaxy.init.erb"

    action     :create
end
bash "add_galaxy_service" do
    code "chkconfig --add galaxy"
    user "root"

    action :run
end
service "galaxy" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
end


