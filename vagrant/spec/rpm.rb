# rpm: pigsty 3-node Enterprise Linux building environment templates: CentOS 7.9 / RockyLinux 8.9 / RockyLinux 9.3

Specs = [

  # CentOS 7.9 / RockyLinux 8.10 / RockyLinux 9.5
  { "name" => "el7",    "ip" => "10.10.10.7" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "generic/centos7"        },
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/rockylinux-8"     },
  { "name" => "el9",    "ip" => "10.10.10.9" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/rockylinux-9"     },

]
