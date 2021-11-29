# CA (ansible role)

This role will provision a usable CA key & cert



### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Create local ca directory	TAGS: [ca, ca_dir, infra]
Copy ca cert from local files	TAGS: [ca, ca_copy, infra]
Check ca key cert exists	TAGS: [ca, ca_create, infra]
Create self-signed CA key-cert	TAGS: [ca, ca_create, infra]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
ca_method: create                 # create|copy|recreate
ca_subject: "/CN=root-ca"         # self-signed CA subject
ca_homedir: /ca                   # ca cert directory
ca_cert: ca.crt                   # ca public key/cert
ca_key: ca.key                    # ca private key
```