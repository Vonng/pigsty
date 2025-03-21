# deb: pigsty 3-node legacy building environment templates:

Specs = [

  # CentOS 7.9 / Debian 11.11 / Ubuntu 20.04.6
  { "name" => "el7",    "ip" => "10.10.10.7" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/centos7"        },
  { "name" => "d11",    "ip" => "10.10.10.11",  "cpu" => "1",  "mem" => "2048",  "image" =>  "debian/bullseye64"      },
  { "name" => "u20",    "ip" => "10.10.10.20",  "cpu" => "1",  "mem" => "2048",  "image" =>  "alvistack/ubuntu-20.04" },

]
