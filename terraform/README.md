# Terraform Templates

[Terraform](https://www.terraform.io/) is a popular IaC tool. You can create VMs on public cloud with one command.

AWS & Aliyun templates are used as example providers. You can modify `terraform.tf` file to use other cloud providers.



## Specifications

* [spec/aws.tf](spec/aws.tf) : AWS 4 node CentOS7 environment
* [spec/aliyun.tf](spec/aliyun.tf) : Aliyun 4 node CentOS7 environment



## Quick Start

```bash
brew install terraform    # install via homebrew
terraform init            # install terraform provider: aliyun , aws, only required for the first time
terraform apply           # plan and apply: create VMs, etc...
```

Print public IP Address:

```bash
terraform output | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
```



## AWS Credential

You have to set up aws config & credential to use AWS provider. 

```bash
# ~/.aws

# ~/.aws/config
[default]
region = cn-northwest-1

# ~/.aws/credentials
[default]
aws_access_key_id = <YOUR_AWS_ACCESS_KEY>
aws_secret_access_key =  <AWS_ACCESS_SECRET>

# ~/.aws/pigsty-key
# ~/.aws/pigsty-key.pub
```


## Caveat

Aliyun CentOS 7 have a problem with `nscd` package, remove them to avoid glibc conflict.
