# pigsty 4 nodes EL7 sandbox: rhel7, centos7, oracle7, alma7
EL_VERSION = "8"
Images = {
  "RHEL"   => { "7"=> "generic/rhel7"   , "8"=> "generic/rhel8"   , "9"=> "generic/rhel9"   },
  "CentOS" => { "7"=> "generic/centos7"                                                     },
  "Rocky"  => {                           "8"=> "generic/rocky8"  , "9"=> "generic/rocky9"  },
  "Oracle" => { "7"=> "generic/oracle7" , "8"=> "generic/oracle8" , "9"=> "generic/oracle9" },
  "Alma"   => { "7"=> "generic/alma7"   , "8"=> "generic/alma8"   , "9"=> "generic/alma9"   },
}
Specs = [
  { "name" => "meta"  , "ip" => "10.10.10.10", "cpu" => "2", "mem" => "4096", "image" =>  Images["RHEL"][EL_VERSION]   },
  { "name" => "node-1", "ip" => "10.10.10.11", "cpu" => "1", "mem" => "2048", "image" =>  Images["Rocky"][EL_VERSION]  },
  { "name" => "node-2", "ip" => "10.10.10.12", "cpu" => "1", "mem" => "2048", "image" =>  Images["Oracle"][EL_VERSION] },
  { "name" => "node-3", "ip" => "10.10.10.13", "cpu" => "1", "mem" => "2048", "image" =>  Images["Alma"][EL_VERSION]   },
]
