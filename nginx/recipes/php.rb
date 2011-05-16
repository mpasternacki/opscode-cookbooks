include_recipe "nginx"

%w(php5 php5-cgi lighttpd).each do |pkg|
  package pkg
end

service "lighttpd" do
  action [:stop, :disable]
end

# http://www.adminsehow.com/2009/05/how-to-configure-nginx-php5-mysql-on-debian-5-lenny/
cookbook_file "/etc/init.d/php-fastcgi" do
  source "php-fastcgi.init"
  mode "0755"
end

cookbook_file "/etc/default/php-fastcgi" do
  source "php-fastcgi.default"
  mode "0644"
end

service "php-fastcgi" do
  action [:enable, :start]
end

directory "/etc/nginx/conf-include.d"
cookbook_file "/etc/nginx/conf-include.d/php" do
  source "php.conf"
end
