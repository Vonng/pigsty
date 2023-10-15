# pigsty minio testing environment with 3 nodes x 2C4G and an extra disk

# You have to enable experimental feature with export environment variable:
# check https://developer.hashicorp.com/vagrant/docs/disks/usage for details
# VAGRANT_EXPERIMENTAL="disks"

Specs = [
  { "name" => "minio-1"       , "ip" => "10.10.10.10"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "minio-2"       , "ip" => "10.10.10.11"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
  { "name" => "minio-3"       , "ip" => "10.10.10.12"   , "cpu" => "2"    , "mem" => "4096"    , "image" =>  "generic/rocky8"  },
]

