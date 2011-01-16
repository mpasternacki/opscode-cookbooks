include_recipe "build-essential"

%w(autoconf m4 quilt unixodbc-dev bison flex libsctp-dev).each do |p|
  package p
end

SOURCE_TARBALL = File.join(Chef::Config[:file_cache_path], "otp_src_#{node[:erlang][:src_version]}.tar.gz")

remote_file SOURCE_TARBALL do
  checksum node[:erlang][:src_checksum]
  source node[:erlang][:src_mirror]
end

bash "install erlang #{node[:erlang][:src_version]}" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -zxf #{SOURCE_TARBALL}
    cd otp_src_#{node[:erlang][:src_version]} && ./configure && make && make install
  EOH
  not_if { ::FileTest.exists?("/usr/local/bin/erl") }
end
