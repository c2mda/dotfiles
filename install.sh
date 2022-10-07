# Assumes Ubuntu / apt.
folder=$(dirname -- "$0";)

maybe_copy () {
  from=$1
  to=$2
  if [ -e $to ] || [ -L $to ]; then
    echo "File $to already exists, comparing."
    if ! cmp $from $to >/dev/null 2>&1; then
      echo "Files $from and $to differ, removing $to."
      rm $to
      echo "Copying from $from to $to."
      cp $from $to
    else
      echo "Files $from and $to match, skipping."
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

# Setup vim swap folder.
mkdir -p ~/.vim/swap

# Install Vundle.
if ! [ -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install vim plugins.
vim +PluginInstall +qall

# Some stuff needed for YouCompleteMe in vim.
# A bit heavy but couldn't find a good lighter autocomplete.
sudo apt-get update
sudo apt install build-essential cmake vim-nox python3-dev
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all

# Required for Python3 formatting.
pip install autopep8, reorder-python-imports, pylint

# Install FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --update-rc

# Install fd finder
sudo apt install fd-find

# Install kubectl.
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo mkdir -p ~/.kube
# sudo cp /mnt/volumetrialcyp/cw-kubeconfig ~/.kube/config

# Install useful stuff.
sudo apt install python3.8-venv
