export PATH="$PATH:@coreutils@/bin:@bash@/bin:@git@/bin:@findutils@/bin:@gnused@/bin"
export DOTFILES_URL="git@github.com:jakubgs/dotfiles.git"
export DOTFILES_PATH="${HOME}/dotfiles"

if [[ -d "${DOTFILES_PATH}" ]]; then
    echo "Dotfiles already cloned."
else
    echo "Cloning dotfiles repository..."
    export GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    git clone "${DOTFILES_URL}" "${DOTFILES_PATH}"
fi

echo "Symlinking configuration..."
${DOTFILES_PATH}/bin/symlinkconf
