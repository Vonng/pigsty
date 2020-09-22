# Vagrant Provision Guide

If you wish to run pigsty on your laptop, consider using vagrant and virtualbox as vm provisioner

1. Install  [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://www.ansible.com/) on your computer. for example:

  ```bash
brew install virtualbox vagrant ansible 	# MacOS, other may not work this way
  ```

2. Use vagrant with [`Vagrantfile`](vagrant/Vagrantfile), ti will provision 4 nodes (via [virtualbox](https://www.virtualbox.org/)) for this project.

  ```bash
make up     # pull up vm nodes. alternative: cd vagrant && vagrant up
  ```

3. Setup nopass ssh from your host to vm nodes

  ```bash
make ssh		# cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config
  ```

4. There are some vagrant shortcuts defined in [Makefile](Makefile) 

```bash
make				# launch cluster
make new    # create a new pigsty cluster
make dns		# write pigsty dns record to your /etc/hosts (sudo required)
make ssh		# write ssh config to your ~/.ssh/config
make clean	# delete current cluster
make cache	# copy local yum repo packages to your pigsty/pkg
```

