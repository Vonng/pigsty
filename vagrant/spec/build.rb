# pigsty 3 nodes building environment: centos7 / rocky8 / rocky9
Specs = [
  {"name" => "meta",   "ip" => "10.10.10.10", "cpu" => "2",  "mem" => "8192", "image" => "generic/centos7" },
  {"name" => "node-1", "ip" => "10.10.10.11", "cpu" => "2",  "mem" => "8192", "image" => "generic/rocky8"  },
  {"name" => "node-2", "ip" => "10.10.10.12", "cpu" => "2",  "mem" => "8192", "image" => "generic/rocky9"  },
]

# Alternative building env: rhel7 / rhel8 / rhel9
# Specs = [
#   {"name" => "meta",   "ip" => "10.10.10.10", "cpu" => "2",  "mem" => "4096", "image" => "generic/rhel7" },
#   {"name" => "node-1", "ip" => "10.10.10.11", "cpu" => "2",  "mem" => "4096", "image" => "generic/rhel8" },
#   {"name" => "node-2", "ip" => "10.10.10.12", "cpu" => "2",  "mem" => "4096", "image" => "generic/rhel9" },
# ]
