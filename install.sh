#!/usr/bin/env bash
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Full or minimal setup (full: no apt-get)
# Default to minimal
if [[ ${1:--minimal} == "--full" ]]; then
  minimal=false
else
  minimal=true
fi

# Assumes Ubuntu / apt.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

maybe_copy () {
  # Copy from -> to if differing or non existent.
  from=$1
  to=$2
  if [ -e "$to" ] || [ -L "$to" ]; then
    if ! cmp "$from" "$to" >/dev/null 2>&1; then
      echo "Files $from and $to differ, overwriting $to."
      mv -f "$to" "${to}.bak"
      ln -s "$from" "$to"
      return 0
    fi
  else
    echo "File $to doesn't exist, copying from $from to $to."
    ln -s "$from" "$to"
    return 0
  fi
  return 1
}

# To avoid running apt-get update every time.
apt_updated=false

# Returns true (0 in bash) if any package has been installed.
function maybe_apt_install() {
  if [ "$minimal" == "true" ]; then return 0; fi
  local any_install=false
  for package_name in "$@"; do
    local status
    status=$(dpkg-query --show --showformat='${db:Status-Status}\n' "${package_name}")
    if [ ! "${status}" = "installed" ]; then
      echo "Installing ${package_name}"
      if [ ! "${apt_updated}" = true ]; then
        sudo apt-get -qq -o=Dpkg::Use-Pty=0Q update
        apt_updated=true
      fi
      sudo apt-get -qq -o=Dpkg::Use-Pty=0Q install --no-upgrade "${package_name}"
      any_install=true
    fi
  done
  if [ $any_install = true ]; then return 0; fi
  return 1
}


# Note: also needs to upload ssh private key.
git config --global user.email "cyprien.de.masson@gmail.com"
git config --global user.name "Cyprien de Masson"

maybe_copy "${SCRIPT_DIR}/.inputrc" ~/.inputrc
maybe_copy "${SCRIPT_DIR}/.vimrc" ~/.vimrc
maybe_copy "${SCRIPT_DIR}/.bash_profile" ~/.bash_profile
maybe_copy "${SCRIPT_DIR}/.bashrc" ~/.bashrc
maybe_copy "${SCRIPT_DIR}/.tmux.conf" ~/.tmux.conf
maybe_copy "${SCRIPT_DIR}/.pylintrc" ~/.pylintrc
maybe_copy "${SCRIPT_DIR}/rc" ~/.ssh/rc

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
    cd ~/.vim/plugged/YouCompleteMe || exit
    python3 install.py
  fi
fi

########### END MINIMAL SETUP #########
if [ "$minimal" == "true" ]; then exit 0; fi

# Debian packages.

# Needed for YCM
maybe_apt_install build-essential cmake vim-nox python3-dev shellcheck

# Generally useful.
if ! apt-cache policy | grep deadsnakes &>/dev/null; then
  echo "Adding deadsnakes/ppa to repositories."
  sudo add-apt-repository --yes ppa:deadsnakes/ppa
fi
maybe_apt_install python3.10 awscli python3.10-venv jq rclone libffi-dev python3.10-dev docker.io universal-ctags

# Make available on other machines sharing $HOME
fd_installed=$(maybe_apt_install "fd-find")
if [ "$fd_installed" = true ]; then
  cp /usr/bin/fdfind $HOME/bin/
fi

# Make available on other machines sharing $HOME
rclone_installed=$(maybe_apt_install "rclone")
if [ "$rclone_installed" = true ]; then
  cp /bin/rclone $HOME/bin/
fi
 
# Make available on other machines sharing $HOME
rg_installed=$(maybe_apt_install "ripgrep")
if [ "$rg_installed" = true ]; then
  cp /usr/bin/rg $HOME/bin/
fi

pip_installed=$(maybe_apt_install "python3-pip")
if [ "$pip_installed" = true ]; then
  pip install --quiet autopep8 reorder-python-imports pylint black ruff poetry mypy flake8 isort
fi

if ! command -v bat --version &> /dev/null; then
  echo "Installing bat"
  maybe_apt_install bat

  # Bat is installed as batcat due to name clash.
  mkdir -p ~/.local/bin
  ln -s /usr/bin/batcat ~/.local/bin/bat
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

if ! command -v gh --version &> /dev/null; then
  echo "Installing github CLI"
  # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
  # Make available on other machines sharing $HOME
  cp /usr/bin/gh $HOME/bin/
fi

# Tanka
if ! command -v tk --version &> /dev/null; then
  echo "Installing tanka"
  sudo curl -Lo /usr/local/bin/tk https://github.com/grafana/tanka/releases/latest/download/tk-linux-amd64
  sudo chmod a+x /usr/local/bin/tk
fi
