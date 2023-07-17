#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Assumes Ubuntu / apt.
folder=$(dirname -- "$0";)

maybe_copy () {
  from=$1
  to=$2
  if [ -e "$to" ] || [ -L "$to" ]; then
    if ! cmp "$from" "$to" >/dev/null 2>&1; then
      echo "Files $from and $to differ, overwriting $to."
      cp -f "$from" "$to"
    fi
  else
    echo "File $to doesn't exist, copying from $from to $to."
    cp "$from" "$to"
  fi
}

# To avoid running apt-get update every time.
apt_updated=false

function maybe_apt_install() {
  package_name=$1
  if ! dpkg-query --show --showformat='${db:Status-Status}\n' python3.8-venv &> /dev/null; then
    echo "Installing python3.8-venv"

    if [ ! "${apt_updated}" = true ]; then
      sudo apt-get -qq -o=Dpkg::Use-Pty=0Q update
      apt_updated=true
    fi
    sudo apt-get -qq -o=Dpkg::Use-Pty=0Q install --no-upgrade "${package_name}"
  else
    # Nothing installed.
    return 1
  fi
}

# Note: also needs to upload ssh private key.
git config --global user.email "cyprien.de.masson@gmail.com"
git config --global user.name "Cyprien de Masson"

maybe_copy "${folder}/.inputrc" ~/.inputrc
maybe_copy "${folder}/.vimrc" ~/.vimrc
maybe_copy "${folder}/.bash_profile" ~/.bash_profile
maybe_copy "${folder}/.bashrc" ~/.bashrc
maybe_copy "${folder}/.tmux.conf" ~/.tmux.conf
maybe_copy "${folder}/.pylintrc" ~/.pylintrc
maybe_copy "${folder}/rc" ~/.ssh/rc

# shellcheck source=/home/cyprien/.bash_profile
source "${HOME}/.bash_profile"

if [ -n "${TMUX:-}" ]; then
  tmux source ~/.tmux.conf
fi

if [[ ! -a "$HOME/.fzf" ]]; then
  echo "Installing FZF"
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --update-rc
  # Reload to get key bindings.
  # shellcheck source=/home/cyprien/.bashrc
  source ~/.bashrc
fi

# Debian packages.

# Needed for YCM
maybe_apt_install "build-essential"
maybe_apt_install "cmake"
maybe_apt_install "vim-nox"
maybe_apt_install "python3-dev"

# Generally useful.
maybe_apt_install "fd-find"
maybe_apt_install "awscli"
maybe_apt_install "python3.8-venv"
maybe_apt_install "python3-pip"
if $?; then
  pip install --quiet autopep8 reorder-python-imports pylint black ruff
fi

# Vim
mkdir -p ~/.vim/swap
if [ ! -e ~/.vim/autoload/plug.vim ]; then
  echo "Installing vimplug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  # Install vim plugins.
  vim +PlugInstall +qall

  # Some stuff needed for YouCompleteMe in vim.
  # A bit heavy but couldn't find a good lighter autocomplete.
  if ! ( ls ~/.vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.*.so &> /dev/null ) ; then
    cd ~/.vim/plugged/YouCompleteMe
    python3 install.py
  fi
fi

# Cloud
if [[ ! -a /usr/local/bin/kubectl ]]; then
  echo "Installing kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  mkdir -p ~/.kube
fi

if ! command -v oci --version &> /dev/null; then
  echo "Installing Oracle CLI"
  # https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
  bash <(curl -s https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh) --accept-all-defaults
fi
