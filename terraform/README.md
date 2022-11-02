# Terraform Templates

[Terraform](https://www.terraform.io/) is a popular IaC tool.
You can create VMs on public cloud with one command.

AWS & Aliyun templates are used as example providers. 
You can modify `terraform.tf` file to use other cloud providers.



## Specifications

* [spec/aws.tf](spec/aws.tf) : AWS 4 node CentOS7 environment
* [spec/aliyun.tf](spec/aliyun.tf) : Aliyun 4 node CentOS7 environment



## Quick Start

```bash
brew install terraform    # install via homebrew
terraform init      # 安装 terraform provider: aliyun （仅第一次需要）
terraform apply     # 生成执行计划：创建虚拟机，虚拟网段/交换机/安全组
```

Print public IP Address:

```bash
terraform output | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
```



## AWS Credential

You have to setup aws config & credential to use AWS provider. 

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
