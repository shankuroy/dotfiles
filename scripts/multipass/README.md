# [Canonical Multipass](https://documentation.ubuntu.com/multipass/latest/)

Spin up Ubuntu VMs that use cloud images and support cloud-init scripts.

```bash
brew install --cask multipass
```

```bash
multipass launch lts --cloud-init ubuntu.cloud-init.yaml --cpus 2 --memory 4G --disk 20G -vvvv --name ubuntu
```

```bash
multipass shell ubuntu
```

```bash
multipass stop ubuntu
multipass delete ubuntu
multipass purge
```

