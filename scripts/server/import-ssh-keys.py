"""
SSH Key Sync Utility
-------------------
Fetches public SSH keys from GitHub for a specified user and appends them
to the local user's '~/.ssh/authorized_keys' file. It automatically
ensures correct file permissions and ignores keys that are already present.

Usage:
    - Run locally:
      python3 update_keys.py [username]

    - Run via curl pipeline:
      curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/import-ssh-keys.py | python3 - [username]

    * If [username] is omitted, it defaults to 'shankuroy'.
"""

import sys
import urllib.request
from pathlib import Path

# Get username from arguments, default to 'shankuroy' if none provided
username = sys.argv[1] if len(sys.argv) > 1 else "shankuroy"

URL = f"https://github.com/{username}.keys"
AUTH_KEYS_PATH = Path.home() / ".ssh" / "authorized_keys"

print(f"Fetching keys for GitHub user: {username}...")

# Ensure .ssh directory and authorized_keys file exist with strict permissions
AUTH_KEYS_PATH.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
AUTH_KEYS_PATH.touch(mode=0o600, exist_ok=True)

try:
    # Fetch and parse remote keys
    with urllib.request.urlopen(URL) as response:
        remote_keys = {
            line.decode().strip()
            for line in response
            if line.strip().startswith(b"ssh-")
        }
except Exception as e:
    print(f"Failed to fetch keys from {URL}: {e}")
    raise SystemExit(1)

if not remote_keys:
    print(f"No keys found for user '{username}'.")
    raise SystemExit(0)

# Read existing local keys
with open(AUTH_KEYS_PATH, "r") as f:
    local_keys = {line.strip() for line in f if line.strip()}

# Identify missing keys
new_keys = remote_keys - local_keys

# Append only the new keys
if new_keys:
    with open(AUTH_KEYS_PATH, "r+") as f:
        content = f.read()
        if content and not content.endswith("\n"):
            f.write("\n")
        f.write("\n".join(new_keys) + "\n")
    print(f"Successfully added {len(new_keys)} new key(s) for {username}.")
else:
    print(f"All keys for {username} are already up to date.")

