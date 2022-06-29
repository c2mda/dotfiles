folder=$(dirname -- "$0";)

maybe_copy () {
  from=$1
  to=$2
  if [ -e $to] || [ -L $to ]; then
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

maybe_link ${folder}/.inputrc ~/.inputrc 
maybe_link ${folder}/.vimrc ~/.vimrc 
maybe_link ${folder}/.bashrc ~/.bashrc 
