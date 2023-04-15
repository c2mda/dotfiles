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
  if [ -e $to ] || [ -L $to ]; then
    if ! cmp $from $to >/dev/null 2>&1; then
      echo "Files $from and $to differ, overwriting $to."
      cp -f $from $to
    fi
  else
    echo "File $to doesn't exist, copying from $from to $to."
    cp $from $to
  fi
}

# Note: also needs to upload ssh private key.
git config --global user.email "cyprien.de.masson@gmail.com"
git config --global user.name "Cyprien de Masson"

maybe_copy ${folder}/.inputrc ~/.inputrc
maybe_copy ${folder}/.vimrc ~/.vimrc
maybe_copy ${folder}/.bash_profile ~/.bash_profile
maybe_copy ${folder}/.bashrc ~/.bashrc
maybe_copy ${folder}/.tmux.conf ~/.tmux.conf
maybe_copy ${folder}/.pylintrc ~/.pylintrc
maybe_copy ${folder}/rc ~/.ssh/rc

source ~/.bash_profile
tmux source ~/.tmux.conf

# Install FZF
if [[ ! -a "$HOME/.fzf" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --update-rc
fi

# Install fd finder
sudo apt-get -qq -o=Dpkg::Use-Pty=0Q install --no-upgrade fd-find

# Setup vim swap folder.
mkdir -p ~/.vim/swap

# Install vim-plug.
if ! [ -d ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install vim plugins.
vim +PlugInstall +qall

# Some stuff needed for YouCompleteMe in vim.
# A bit heavy but couldn't find a good lighter autocomplete.
if ! ( ls ~/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core.*.so &> /dev/null ) ; then
  sudo apt-get -qq -o=Dpkg::Use-Pty=0Q update
  sudo apt-get -qq -o=Dpkg::Use-Pty=0Q install --no-upgrade build-essential \
    cmake vim-nox python3-dev
  cd ~/.vim/plugged/YouCompleteMe
  python3 install.py
fi

# Install pip
sudo apt-get -qq -o=Dpkg::Use-Pty=0Q install --no-upgrade python3-pip

# Required for Python3 formatting.
pip install --quiet autopep8 reorder-python-imports pylint

# Install kubectl.
if [[ ! -a /usr/local/bin/kubectl ]]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  sudo mkdir -p ~/.kube
fi
# sudo cp /mnt/volumetrialcyp/cw-kubeconfig ~/.kube/config

# Install virtual env.
sudo apt-get -qq -o=Dpkg::Use-Pty=0Q install --no-upgrade python3.8-venv
