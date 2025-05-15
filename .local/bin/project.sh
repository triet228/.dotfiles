
#!/bin/bash

# Usage: ./make_py_project.sh project_name

NAME=$1
DIR=~/Projects/$NAME

mkdir -p "$DIR"
cd "$DIR" || exit

# Create venv
python -m venv venv

# Create direnv config
echo "source ./venv/bin/activate" > .envrc
direnv allow

# Add basic files
touch script.py requirements.txt

# Copy path to clipboard
echo "$DIR" | xclip -selection clipboard


echo "✅ Project '$NAME' created at $DIR with venv + direnv."

