#!/usr/bin/env sh

# ------------------------------------------------------------------------------
# Bootstrap SSH keys and Git configuration for a new machine.
#
# This script sets up profile-based SSH keys and Git configs, making it easy
# to work with multiple GitHub (or other Git) identities on the same machine.
#
# Profiles can be provided in three ways (in priority order):
#
#   1. Command-line arguments:
#        ./bootstrap.sh personal work
#
#   2. The PROFILES environment variable:
#        PROFILES="personal work" ./bootstrap.sh
#
#   3. Defaults:
#        personal work
#
# For each profile, this script will:
#   - Generate an ED25519 SSH key (if missing)
#   - Add it to the running SSH agent
#   - Create a profile-specific SSH host entry
#   - Create a profile-specific Git config
#   - Set up Git includeIf rules based on repo location
#
# Re-running this script is safe; existing files are not overwritten.
# ------------------------------------------------------------------------------

# ----- parse arguments -----

if [ "$#" -gt 0 ]; then
  profiles="$*"
else
  profiles=${PROFILES:-"personal work"}
fi

echo "INFO: setting up SSH and git config for the following profiles:"
echo "      ${profiles}"

# ----- variables -----

ssh_dir="${HOME}/.ssh"
repo_base_git="~/repo"          # used in gitconfig (tilde required)
repo_base_fs="${HOME}/repo"     # used for filesystem operations
target_gitconfig="${HOME}/.gitconfig"

# ----- ensure SSH agent is running -----

echo "INFO: checking for running SSH agent"

if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  echo "❌ ERROR: SSH agent is not running."
  echo "   Start one first (e.g. 'eval \$(ssh-agent -s)') and re-run."
  exit 1
fi

echo "INFO: SSH agent detected"

# ----- setup ~/.ssh structure -----

mkdir -p "${ssh_dir}/config.d"

if [ ! -f "${ssh_dir}/config" ]; then
  cat << EOF > "${ssh_dir}/config"
Host *
  AddKeysToAgent yes
  IdentitiesOnly yes

Include ~/.ssh/config.d/*.conf
EOF
  echo "INFO: created ${ssh_dir}/config"
else
  echo "INFO: ${ssh_dir}/config already exists"
fi

# ----- generate SSH keys and per-profile SSH config -----

for profile in $profiles; do
  profile_key="${ssh_dir}/id_ed25519_${profile}"
  profile_conf="${ssh_dir}/config.d/${profile}.conf"

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

# ----- add keys to SSH agent -----

for profile in $profiles; do
  profile_key="${ssh_dir}/id_ed25519_${profile}"

  if [ -f "${profile_key}" ]; then
    ssh-add -l | grep -q "${profile_key}" || ssh-add "${profile_key}"
    echo "INFO: ensured SSH agent has key for profile '${profile}'"
  fi
done

# ----- setup gitconfig -----

if [ -f "${target_gitconfig}" ]; then
  if [ ! -f "${target_gitconfig}.bak" ]; then
    cp "${target_gitconfig}" "${target_gitconfig}.bak"
    echo "INFO: backed up existing ~/.gitconfig to ~/.gitconfig.bak"
  fi
else
  cat << EOF > "${target_gitconfig}"
[user]
  useConfigOnly = true

[core]
  excludesfile = ~/.gitignore_global

EOF
  echo "INFO: created ${target_gitconfig}"
fi

# ----- create repo directories -----

for profile in $profiles; do
  repo_dir="${repo_base_fs}/${profile}"

  if [ -d "${repo_dir}" ]; then
    echo "INFO: repo directory exists: ${repo_dir}"
  else
    mkdir -p "${repo_dir}"
    echo "INFO: created repo directory: ${repo_dir}"
  fi
done

# ----- add git includeIf rules -----

for profile in $profiles; do
  if ! grep -q "gitdir:${repo_base_git}/${profile}/" "${target_gitconfig}"; then
    cat << EOF >> "${target_gitconfig}"
[includeIf "gitdir:${repo_base_git}/${profile}/"]
    path = ~/.gitconfig-${profile}

EOF
    echo "INFO: added git includeIf for profile '${profile}'"
  fi
done

# ----- create per-profile gitconfig files -----

for profile in $profiles; do
  profile_gitconfig="${target_gitconfig}-${profile}"

  if [ -f "${profile_gitconfig}" ]; then
    echo "⚠️  WARN: ${profile_gitconfig} already exists (check/edit before use)"
  else
    cat << EOF > "${profile_gitconfig}"
[user]
    name = CHANGEME (${profile})
    email = ID+USERNAME@users.noreply.github.com
EOF
    echo "✅ INFO: created ${profile_gitconfig} (edit before use)"
  fi
done

# ----- print public keys -----

echo ""
echo "✅ Add these public keys to the relevant accounts:"
echo "   https://github.com/settings/ssh/new"
echo ""

for profile in $profiles; do
  cat "${ssh_dir}/id_ed25519_${profile}.pub"
  echo ""
done

echo ""
echo "ℹ️  Clone repositories into the matching directory using the profile host:"
for profile in $profiles; do
  echo "    cd ${repo_base_git}/${profile}"
  echo "    git clone git@github.com-${profile}:OWNER/REPO.git"
  echo ""
done


echo ""
echo "⭐️ Bootstrap complete!"

