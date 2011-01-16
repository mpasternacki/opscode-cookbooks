maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs erlang, optionally install GUI tools."
version           "0.8.2"

recipe "erlang", "Installs erlang"
recipe "erlang::source", "Installs erlang from source"

depends "build-essential"

%w{ ubuntu debian }.each do |os|
  supports os
end
