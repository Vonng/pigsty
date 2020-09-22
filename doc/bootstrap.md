# Bootstrap Guide



## Offline Installation

Sometimes you may not have Internet access. Offline installtion is prepared for this. (But currently only Cent 7 is supported)

It may takes around 5m~30m to download all packages (1GB) according to your network condition. Consider using a local [http proxy](group_vars/dev.yml), and don't forget to make a package cache via  `make cache` after bootstrap. 

You can also download a pre-made packages cache [pkg.tgz](), but this only works for CentOS 7.6. Download pkg.tgz and put it under your meta local yum repo dir, (`/www/pigsty` by default).

Another tricky thing is that if you wish to run playbooks on meta node that does not have `ansible` installed. You may have to install it from cache via local file repo. Refer [this](roles/repo/templates/bootstrap.sh.j2)

