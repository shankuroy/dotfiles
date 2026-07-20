#!/usr/bin/env bash

MISE_TOML='mise.toml.example'
GITIGNORE='python_gitignore'

if [ -n "${1:-}" ]; then
    PROJECT_NAME="$1"
else
    read -rp "Enter project name: " PROJECT_NAME
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "ERROR: project name cannot be empty." >&2
    exit 1
fi

if [[ -d "$PROJECT_NAME" ]]; then
    echo "ERROR: project '$PROJECT_NAME' already exists." >&2
    exit 1
fi

mkdir "$PROJECT_NAME"
cp "$MISE_TOML" "$PROJECT_NAME/mise.toml"
cp "$GITIGNORE" "$PROJECT_NAME/.gitignore"

cat <<EOF
New project created in directory: $PROJECT_NAME
Next steps:
  cd $PROJECT_NAME
  mise trust
  mise install
  uv init .        # only if pyproject.toml doesn't exist
  uv sync          # only if uv.lock doesn't exist
  cd ..
  cd -
EOF

