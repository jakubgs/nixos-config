#!@shell@
set -e

export PATH="@path@"
export DOTFILES_PATH="${HOME}/dotfiles"
export DOTFILES_URL='@dotfilesUrl@'
export DOTFILES_URL_HTTPS="${DOTFILES_URL/git@github.com:/https://github.com/}"
export DOTFILES_BRANCH='@dotfilesBranch@'
export GIT_SSH_COMMAND='ssh -i @sshKey@ -o StrictHostKeyChecking=accept-new'

if [[ ! -d "${DOTFILES_PATH}" ]]; then
    echo "Cloning dotfiles repository..."
    git clone "${DOTFILES_URL}" "${DOTFILES_PATH}"
else
    echo "Fetching dotfiles new changes..."
    cd "${DOTFILES_PATH}"
    # HTTPS is faster for branch commit check that SSH.
    REMOTE_COMMIT=$(git ls-remote --branches "${DOTFILES_URL_HTTPS}" master | cut -f1)
    if [[ "${REMOTE_COMMIT}" != "$(git rev-parse HEAD)" ]]; then
        git pull --rebase --autostash origin "${DOTFILES_BRANCH}"
    else
        exit 0
    fi
fi

echo "Symlinking configuration..."
${DOTFILES_PATH}/bin/symlinkconf
