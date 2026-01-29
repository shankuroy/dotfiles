#!/usr/bin/env sh

# ------------------------------------------------------------------------------
# Teardown SSH keys and Git configuration created by the bootstrap script.
#
# This script removes:
#   - Profile-specific SSH keys
#   - Profile-specific SSH config snippets
#   - Profile-specific Git config files
#   - Profile-specific repo directories (optional, prompted)
#
# It DOES NOT:
#   - Delete ~/.ssh/config
#   - Delete ~/.ssh/config.d if other files exist
#   - Delete ~/.gitconfig (only edits are left as-is)
#
# This script is intentionally conservative.
# ------------------------------------------------------------------------------

# ----- parse arguments -----

if [ "$#" -gt 0 ]; then
  profiles="$*"
else
  profiles=${PROFILES:-"personal work"}
fi

echo "⚠️  TEARDOWN MODE"
echo "INFO: the following profiles will be removed:"
echo "      ${profiles}"
echo ""

# ----- variables -----

ssh_path="${HOME}/.ssh"
repo_path="${HOME}/repo"
gitconfig_file="${HOME}/.gitconfig"

# ----- confirmation -----

echo "This will remove SSH keys and Git configs for the profiles above."
printf "Type 'yes' to continue: "
read answer

if [ "$answer" != "yes" ]; then
  echo "INFO: teardown cancelled"
  exit 0
fi

# ----- remove SSH keys and configs -----

for profile in $profiles; do
  echo ""
  echo "INFO: cleaning SSH artifacts for profile '${profile}'"

  priv_key="${ssh_path}/id_ed25519_${profile}"
  pub_key="${priv_key}.pub"
  conf_file="${ssh_path}/config.d/${profile}.conf"

  # Remove from ssh-agent if loaded
  if command -v ssh-add >/dev/null 2>&1; then
    ssh-add -d "${priv_key}" >/dev/null 2>&1
  fi

  if [ -f "${priv_key}" ]; then
    rm -f "${priv_key}"
    echo "  removed ${priv_key}"
  fi

  if [ -f "${pub_key}" ]; then
    rm -f "${pub_key}"
    echo "  removed ${pub_key}"
  fi

  if [ -f "${conf_file}" ]; then
    rm -f "${conf_file}"
    echo "  removed ${conf_file}"
  fi
done

# ----- clean empty SSH config.d directory -----

if [ -d "${ssh_path}/config.d" ] && [ -z "$(ls -A "${ssh_path}/config.d")" ]; then
  rmdir "${ssh_path}/config.d"
  echo ""
  echo "INFO: removed empty ${ssh_path}/config.d"
fi

# ----- remove per-profile gitconfigs -----

for profile in $profiles; do
  profile_gitconfig="${gitconfig_file}-${profile}"

  if [ -f "${profile_gitconfig}" ]; then
    rm -f "${profile_gitconfig}"
    echo "INFO: removed ${profile_gitconfig}"
  fi
done

# ----- repo directories (prompt per profile) -----

echo ""
echo "Optional: remove repo directories under ${repo_path}"
echo "These may contain cloned repositories."

for profile in $profiles; do
  profile_repo_path="${repo_path}/${profile}"

  if [ -d "${repo_path}" ]; then
    printf "Remove %s ? [y/N]: " "${repo_path}"
    read answer

    case "$answer" in
      y|Y)
        rm -rf "${repo_path}"
        echo "  removed ${repo_path}"
        ;;
      *)
        echo "  kept ${repo_path}"
        ;;
    esac
  fi
done

# ----- final notes -----

echo ""
echo "⚠️  NOTE:"
echo "- ${gitconfig_file} was NOT modified."
echo "- includeIf entries for removed profiles may still exist."
echo "- You can safely delete entries manually if desired."
echo ""
echo "🧹 Teardown complete."

