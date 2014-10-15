# Cookbook Name:: galaxy
# Recipe:: nginx
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# install and setting nginx
package "nginx"
service "nginx" do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
template "/etc/nginx/conf.d/default.conf" do
        path "/etc/nginx/conf.d/default.conf"
        source "nginx.conf.erb"
        owner "root"
        group "root"
        mode 0644
        notifies :reload,'service[nginx]'
end

# install wget
package "wget"
