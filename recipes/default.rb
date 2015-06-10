#
# Cookbook Name:: git
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
# Cookbook Name:: git
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
%w{libcurl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-Embed}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "install git #{node[:git][:version]}" do
  creates "/usr/local/src/#{node[:git][:version]}"
  cwd '/usr/local/src'
  user 'root'
  group 'root'
  code <<-EOH
  wget https://www.kernel.org/pub/software/scm/git/git-#{node[:git][:version]}.tar.gz
  tar xzf git-#{node[:git][:version]}.tar.gz
  cd git-#{node[:git][:version]}
  make prefix=/usr/local all
  make prefix=/usr/local install
  rm -f /usr/local/src/git-#{node[:git][:version]}.tar.gz
  EOH
end

bash 'set bashrc for git' do
  not_if 'grep "git-completion.bash" /etc/bashrc'
  user 'root'
  group 'root'
  code <<-EOH
  echo "source /usr/local/src/git-#{node[:git][:version]}/contrib/completion/git-prompt.sh" >> /etc/bashrc
  echo "source /usr/local/src/git-#{node[:git][:version]}/contrib/completion/git-completion.bash" >> /etc/bashrc
  echo "GIT_PS1_SHOWDIRTYSTATE=true" >> /etc/bashrc
  echo "export PS1='\\[\\033[32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[34m\\]\\w\\[\\033[31m\\]\\$(__git_ps1)\\[\\033[00m\\]\\n\\$ '" >> /etc/bashrc
  EOH
end

%w{gitconfig gitignore}.each do |filename|
  template "/usr/local/etc/#{filename}" do
    owner 'root'
    group 'root'
    mode 00644
  end
end

template '/etc/sudoers.d/chef-solo' do
  owner "root"
  group "root"
  mode 00440
end
