# Virtual Machines

## Linux VMs on macOS with [Lima](https://lima-vm.io/docs/)

Note: `lima` is installed with `colima` if you're using that for Docker on macOS (see [containers.md](./containers.md)).

Create and start a VM from a template (see [my templates](../scripts/lima/templates) or lima's templates at `/opt/homebrew/share/lima/templates`):

```bash
limactl create -y --name ubuntu-lts ~/scripts/lima/templates/ubuntu-lts.yml
limactl start ubuntu-lts --mount-none
limactl restart ubuntu-lts
```

After downloading the image, the server provisions in around 90 seconds (on M1 Pro) and restarts in around 15 seconds.

Downloaded images are stored in `~/Library/Caches/lima/download/by-url-sha256` and can be cleared with `limactl prune`.

Ensure SSH config includes lima configs:

```bash
grep -qF "Include ~/.lima/*/ssh.config" ~/.ssh/config || echo "Include ~/.lima/*/ssh.config" >> ~/.ssh/config
```

SSH into the VM with its name prepended with `lima-`:

```bash
ssh lima-ubuntu-lts
```

Other common operations:

```bash
limactl list                                # list vms and their status
limactl shell ubuntu-lts                    # open the shell
limactl stop ubuntu-lts                     # shut down the vm
limactl delete ubuntu-lts                   # delete a stopped vm
limactl clone ubuntu-lts ubuntu-lts-clone   # clones a stopped vm
```

## macOS VMs on macOS with [Lume](https://cua.ai/docs/lume/guide/getting-started/introduction)

TODO