folder=$(dirname -- "$0";)

maybe_link () {
  from=$1
  to=$2
  echo "Linking from $from to $to" 

  if [[ -f $from ]]; then
    echo "File $from already exists, comparing."
    if ! cmp $from $to >/dev/null 2>&1; then
      echo "Files $from and $to differ, removing $from."
      rm ~/.inputrc
      echo "Linking from $from to $to."
      ln -s $to $from 
    else
      echo "Files $from and $to match, skipping."
    fi
  else
    echo "Linking from $from to $to."
    ln -s $to $from 
  fi
}

maybe_link ~/.inputrc ${folder}/.inputrc  
maybe_link ~/.vimrc ${folder}/.vimrc
maybe_link ~/.bashrc ${folder}/.bashrc
