# Python

## Starting a project with mise/uv

```bash
mkdir project
cd project
cp ../python_gitignore .gitignore
cp ../mise.toml.example mise.toml
mise trust
mise install
uv init .        # only if pyproject.toml doesn't exist
uv sync          # only if uv.lock doesn't exist
cd ..
cd -
```

