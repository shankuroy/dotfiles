# Lume

## Install

```bash
brew install lume
brew services start lume
lume --version
```

## Download images

```bash
mkdir -p ~/.lume/images
cd ~/.lume/images

# Download latest macOS IPSW
curl -LO "$(lume ipsw 2>/dev/null | tail -1)"

# Download latest Debian ISO from https://debian.mirror.digitalpacific.com.au/debian-cd/current/arm64/iso-cd/
curl -LO "https://debian.mirror.digitalpacific.com.au/debian-cd/current/arm64/iso-cd/debian-13.4.0-arm64-netinst.iso"
```


## Create and install an OS in a VM

```bash
# macOS
lume create macos-tahoe-sandbox --os macos --ipsw ~/.lume/images/UniversalMac_26.4.1_25E253_Restore.ipsw

# Debian
lume create debian-sandbox --os linux
```

```bash
# macOS
lume run macos-tahoe-sandbox

# Debian
lume run debian-sandbox --mount ~/.lume/images/debian-13.4.0-arm64-netinst.iso
```


### Set up Debian

Follow the install instructions and login. Add <username> to sudoers:

```bash
su -
apt update && apt upgrade
apt install sudo ufw
usermod -aG sudo <username>
ufw allow ssh
ufw enable
```

Log out and log in again, then test sudo works:

```bash
sudo apt install htop
```

### Set up macOS


Follow the setup steps, then enable remote login:

System Settings > General > Sharing > Remote Login

Install homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the instructions for adding stuff to ~/.zprofile, then test brew works:

```bash
brew update && brew upgrade
brew install htop
```

## Clone a VM

Shut down the VM before cloning.

```bash
lume stop macos-tahoe-sandbox
lume clone macos-tahoe-sandbox macos-tahoe-sandbox-clone
```


## Run a headless VM

```bash
lume run macos-tahoe --no-display
lume run debian-sandbox --no-display
```

Optionally add a shared directory:
```
--shared-dir /path/to/shared/dir
```

Access shared dir in:
- macOS: `/Volumes/My Shared Files`


## SSH

Get the VM's IP from:

```bash
lume get debian-sandbox
```

or

```bash
lume ls
```

Then SSH in:

```bash
ssh <username>@<IP>
```

