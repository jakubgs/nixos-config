#!@shell@
set -e

export PATH="@path@"
export DOTFILES_PATH="${HOME}/dotfiles"
export DOTFILES_URL='@dotfilesUrl@'
export GIT_SSH_COMMAND='ssh -i @sshKey@ -o StrictHostKeyChecking=accept-new'

if [[ ! -d "${DOTFILES_PATH}" ]]; then
    echo "Cloning dotfiles repository..."
    git clone "${DOTFILES_URL}" "${DOTFILES_PATH}"
else
    echo "Fetching dotfiles new changes..."
    cd "${DOTFILES_PATH}"
    git pull --rebase --autostash
fi

echo "Symlinking configuration..."
${DOTFILES_PATH}/bin/symlinkconf
