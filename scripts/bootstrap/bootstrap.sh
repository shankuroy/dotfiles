#!/usr/bin/env sh

usage() {
  cat <<EOF
Create SSH keys and Git configuration for a new machine.

This script sets up profile-based SSH keys and Git configs, making it easy
to work with multiple GitHub (or other Git) identities on the same machine.

Profiles are to be provided as one space-separated argument per profile, e.g.:
  $0 personal work

For each profile, this script will:
  - Generate a passwordless ED25519 SSH key (if missing)
  - Create a profile-specific SSH host entry
  - Create a profile-specific Git config
  - Set up Git includeIf rules based on repo location

Re-running this script is safe. Existing files are not overwritten.

Usage: $0 <profile_name> [profile_name]...
EOF
}

# ----- parse arguments -----

if [ "$#" -gt 0 ]; then
  profiles="$*"
else
  usage $0
  exit 1
fi

echo "INFO: setting up SSH and git config for the following profiles: ${profiles}"

# ----- variables -----

ssh_path="${HOME}/.ssh"
repo_path="${HOME}/repo"
gitconfig_file="${HOME}/.gitconfig"
gitignore_global_file="${HOME}/.gitignore-global"

# ----- setup ~/.ssh structure -----

mkdir -p "${ssh_path}/config.d"

if [ ! -f "${ssh_path}/config" ]; then
  cat << EOF > "${ssh_path}/config"
Host *
  AddKeysToAgent yes
  IdentitiesOnly yes
  SetEnv TERM=xterm-256color

Include ~/.ssh/config.d/*.conf
EOF
  echo "INFO: created ${ssh_path}/config"
else
  echo "INFO: ${ssh_path}/config already exists"
fi

# ----- generate SSH keys and per-profile SSH config -----

for profile in $profiles; do
  profile_key="${ssh_path}/id_ed25519_${profile}"
  profile_conf="${ssh_path}/config.d/${profile}.conf"

  if [ -f "${profile_key}" ]; then
    echo "WARN: SSH key already exists for profile '${profile}'"
  else
    echo "INFO: generating passwordless SSH key for profile '${profile}'"
    ssh-keygen -t ed25519 -f "${profile_key}" -C "${profile}" -N ""
  fi

  if [ ! -f "${profile_conf}" ]; then
    cat << EOF > "${profile_conf}"
Host github.com-${profile}
  HostName github.com
  User git
  IdentityFile ${profile_key}
EOF
    echo "INFO: created SSH config ${profile_conf}"
  fi
done

# ----- create repo directories -----

for profile in $profiles; do
  repo_dir="${repo_path}/${profile}"

  if [ -d "${repo_dir}" ]; then
    echo "INFO: repo directory exists: ${repo_dir}"
  else
    mkdir -p "${repo_dir}"
    echo "INFO: created repo directory: ${repo_dir}"
  fi
done

# ----- setup gitconfig -----

if [ -f "${gitconfig_file}" ]; then
  mkdir -p "${gitconfig_file}.bak"
  gitconfig_backup_file="${gitconfig_file}.bak/gitconfig.bak-$(date '+%F-%H-%M-%S')"
  cp "${gitconfig_file}" "${gitconfig_backup_file}"
  echo "INFO: backed up existing ${gitconfig_file} to ${gitconfig_backup_file}"
else
  cat << EOF > "${gitconfig_file}"
[core]
  excludesfile = ${gitignore_global_file}

[include]
  path = ${gitconfig_file}-all

EOF
  echo "INFO: created ${gitconfig_file}"
fi

# ----- add gitconfig includeIf rules -----

for profile in $profiles; do
  git_dir="gitdir:${repo_path}/${profile}/"

  if ! grep -q "${git_dir}" "${gitconfig_file}"; then
    cat << EOF >> "${gitconfig_file}"
[includeIf "${git_dir}"]
    path = ${gitconfig_file}-${profile}

EOF
    echo "INFO: added git includeIf for profile '${profile}'"
  fi
done

# ----- create per-profile gitconfig files -----

for profile in $profiles; do
  profile_gitconfig="${gitconfig_file}-${profile}"

  if [ -f "${profile_gitconfig}" ]; then
    echo "🔎 INFO: ${profile_gitconfig} already exists (check/edit before use)"
  else
    cat << EOF > "${profile_gitconfig}"
[user]
    name = CHANGEME (${profile_gitconfig})
    email = ID+USERNAME@users.noreply.github.com
EOF
    echo "✅ INFO: created ${profile_gitconfig} (edit before use)"
  fi
done

# ----- print public keys -----

echo ""
echo "✅ Add these public SSH keys to the relevant accounts (https://github.com/settings/keys):"
echo ""

for profile in $profiles; do
  public_key_file="${ssh_path}/id_ed25519_${profile}.pub"
  cat "${public_key_file}"
  echo ""
  echo "  ^ may have already been added with $(ssh-keygen -lf ${public_key_file} | cut -d' ' -f2)"
  echo ""
done

# ----- print repo cloning message

echo ""
echo "ℹ️  Clone repositories into the matching directory using the profile host:"
for profile in $profiles; do
  echo "    cd ${repo_path}/${profile}"
  echo "    git clone git@github.com-${profile}:OWNER/REPO.git"
  echo ""
done

# ----- done! -----

echo ""
echo "⭐️ Bootstrap complete!"

