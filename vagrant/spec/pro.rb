# pro: pigsty 5-node PRO building environment templates

Specs = [

  # RockyLinux 8.10
  { "name" => "el8",    "ip" => "10.10.10.8" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/rockylinux-8"     },

  # RockyLinux 9.5
  { "name" => "el9",    "ip" => "10.10.10.9" ,  "cpu" => "1",  "mem" => "2048",  "image" =>  "bento/rockylinux-9"     },

  # Debian 12.9
  { "name" => "d12",    "ip" => "10.10.10.12",  "cpu" => "1",  "mem" => "2048",  "image" =>  "debian/bookworm64"      },

  # Ubuntu 22.04.5
  { "name" => "u22",    "ip" => "10.10.10.22",  "cpu" => "1",  "mem" => "2048",  "image" =>  "alvistack/ubuntu-22.04" },

  # Ubuntu 24.04.2
  { "name" => "u24",    "ip" => "10.10.10.24",  "cpu" => "1",  "mem" => "2048",  "image" =>  "alvistack/ubuntu-24.04" },

]
