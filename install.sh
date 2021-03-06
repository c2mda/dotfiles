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

git config --global user.email "cyprien.de.masson@gmail.com"
git config --global user.name "Cyprien de Masson"

maybe_copy ${folder}/.inputrc ~/.inputrc 
maybe_copy ${folder}/.vimrc ~/.vimrc 
maybe_copy ${folder}/.bash_profile ~/.bash_profile
maybe_copy ${folder}/.bashrc ~/.bashrc 
maybe_copy ${folder}/.tmux.conf ~/.tmux.conf

# Setup vim swap folder.
mkdir -p ~/.vim/swap

# Install Vundle.
if ! [ -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install vim plugins.
vim +PluginInstall +qall

# Install FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install fd finder
sudo apt install fd-find

# Source bashrc
source ~/.bashrc
