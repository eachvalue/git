#
# Cookbook Name:: git-env
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
# Cookbook Name:: git-env
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

bash "install git #{node['git-env']['version']}" do
  not_if { File.exists?("/usr/src/git") }
  cwd '/usr/src'
  user 'root'
  group 'root'
  code <<-EOH
  wget https://www.kernel.org/pub/software/scm/git/git-#{node['git-env']['version']}.tar.gz
  tar xzf git-#{node['git-env']['version']}.tar.gz
  cd git-#{node['git-env']['version']}
  make prefix=/usr all
  make prefix=/usr install
  source /etc/bashrc
  EOH
end

bash 'set bashrc for git' do
  action :nothing
  not_if 'grep "git-completion.bash" /etc/bashrc'
  user 'root'
  group 'root'
  code <<-EOH
  echo "source /usr/src/git-#{node['git-env']['version']}/contrib/completion/git-prompt.sh" >> /etc/bashrc
  echo "source /usr/src/git-#{node['git-env']['version']}/contrib/completion/git-completion.bash" >> /etc/bashrc
  echo "GIT_PS1_SHOWDIRTYSTATE=true" >> /etc/bashrc
  echo "export PS1='\\[\\033[32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[34m\\]\\w\\[\\033[31m\\]\\$(__git_ps1)\\[\\033[00m\\]\\n\\$ '" >> /etc/bashrc
  EOH
  subscribes :run, 'bash[install git]'
end

%w{gitconfig gitignore}.each do |filename|
  template "/etc/#{filename}" do
    owner 'root'
    group 'root'
    mode 0644
  end
end
