folder=$(dirname -- "$0";)

maybe_link () {
  from=$1
  to=$2
  if [ -e $from ] || [ -L $from ]; then
    echo "File $from already exists, comparing."
    if ! cmp $from $to >/dev/null 2>&1; then
      echo "Files $from and $to differ, removing $from."
      rm $from
      echo "Linking from $from to $to."
      ln -s $to $from
    else
      echo "Files $from and $to match, skipping."
    fi
  else
    echo "File $from doesn't exist, linking from $from to $to."
    ln -s $to $from
  fi
}

git config --global user.email "cyprien.de.masson@gmail.com"
git config --global user.name "Cyprien de Masson"

maybe_link ~/.inputrc ${folder}/.inputrc
maybe_link ~/.vimrc ${folder}/.vimrc
maybe_link ~/.bashrc ${folder}/.bashrc
