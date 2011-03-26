#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node[:munin][:webserver]
when "apache2"
  include_recipe "apache2"
  include_recipe "apache2::mod_auth_openid"
  include_recipe "apache2::mod_rewrite"
when "nginx"
  include_recipe "nginx"
end
include_recipe "munin::client"

package "munin"

case node[:platform]
when "arch"
  cron "munin-graph-html" do
    command "/usr/bin/munin-cron"
    user "munin"
    minute "*/5"
  end
else
  cookbook_file "/etc/cron.d/munin" do
    source "munin-cron"
    mode "0644"
    owner "root"
    group "root"
    backup 0
  end
end

munin_servers = search(:node,
  node[:munin][:client_query] || "munin:[* TO *] AND role:#{node[:app_environment]}")

if node[:public_domain]
  case node[:app_environment]
  when "production"
    public_domain = node[:public_domain]
  else
    public_domain = "#{node[:app_environment]}.#{node[:public_domain]}"
  end
else
  public_domain = node[:domain]
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_servers)
end


directory node['munin']['docroot'] do
  owner "munin"
  group "munin"
  mode 0755
end

case node[:munin][:webserver]
when "apache2"
  apache_site "000-default" do
    enable false
  end

  template "#{node[:apache][:dir]}/sites-available/munin.conf" do
    source "apache2.conf.erb"
    mode 0644
    variables :public_domain => public_domain
    if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/munin.conf")
      notifies :reload, resources(:service => "apache2")
    end
  end
  apache_site "munin.conf"
when "nginx"
  template "#{node[:nginx][:dir]}/sites-available/munin" do
    source "nginx_site.erb"
    mode 0644
    variables :public_domain => public_domain
  end
  nginx_site "munin"
end

