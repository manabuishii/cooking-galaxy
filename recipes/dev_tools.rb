# Cookbook Name:: galaxy
# Recipe:: dev_tools
##
## install tmux, vim
##
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

#install and setting tmux
include_recipe "yum"
## add the EPEL repo
yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
  gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  action :create
end
package "tmux"
template "/etc/tmux.conf" do
        path "/etc/tmux.conf"
        source "tmux.conf.erb"
        owner "root"
        group "root"
        mode 0644
end

# install vim
include_recipe "vim"
