# Download

> What to download?
>
> Where to download?
>
> How to download?



## What to download

Two things needs to be downloaded:

* Pigsty Source Code `pigsty.tgz` (**required**) , ≈500KB
* Pigsty Offline Package `pkg.tgz` (**optional**), ≈1GB

> You can run pigsty **without** `pkg.tgz`: 
>
> It may takes 10~30+ minutes to download packages from original upstream repos.



## Where to download?

* [Github](https://github.com/Vonng/pigsty/releases) (recommended)
* [Baidu](https://pan.baidu.com/s/1DZIa9X2jAxx69Zj-aRHoaw) Netdisk (Mainland China, pass: `8su9`)
* [Official Site](https://pigsty.cc/en/) (Not Recommened)
* Tencent CDN (Obsolete)



## How to download

* `pigsty.tgz` : download and extract to `~/pigsty`
* `pkg.tgz`: download and put to `/tmp/pkg.tgz`.

```bash
VERSION=v1.0.0-alpha2    # replace to specific pigsty version
curl -fsSL https://github.com/Vonng/pigsty/releases/download/${version}/pigsty.tgz -o ~/pigsty.tgz
curl -fSL  https://github.com/Vonng/pigsty/releases/download/${version}/pkg.tgz    -o /tmp/pkg.tgz 
```
