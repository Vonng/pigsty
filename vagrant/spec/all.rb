# deb: pigsty 7-node rocky/debian/ubuntu building environment templates:

Specs = [

  # CentOS 7.9 / RockyLinux 8.10 / RockyLinux 9.5
  { "name" => "el7",    "ip" => "10.10.10.7" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/centos7"        },
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/rockylinux-8"     },
  { "name" => "el9",    "ip" => "10.10.10.9" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/rockylinux-9"     },

  # Debian 11.11 / 12.9
  { "name" => "d11",    "ip" => "10.10.10.11",  "cpu" => "1",  "mem" => "2048",  "image" =>  "debian/bullseye64"      },
  { "name" => "d12",    "ip" => "10.10.10.12",  "cpu" => "1",  "mem" => "2048",  "image" =>  "debian/bookworm64"      },

  # Ubuntu 20.04.6 / 22.04.5 / 24.04.2
  { "name" => "u20",    "ip" => "10.10.10.20",  "cpu" => "1",  "mem" => "2048",  "image" =>  "alvistack/ubuntu-20.04" },
  { "name" => "u22",    "ip" => "10.10.10.22",  "cpu" => "1",  "mem" => "2048",  "image" =>  "alvistack/ubuntu-22.04" },
  { "name" => "u24",    "ip" => "10.10.10.24",  "cpu" => "1",  "mem" => "2048",  "image" =>  "alvistack/ubuntu-24.04" },

]
