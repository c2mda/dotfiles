#!/bin/bash
backup_disks=( /Volumes/backup*/ )
num_backups=${#backup_disks[*]}
echo "Found ${num_backups} disks: ${backup_disks[@]}"

if [ $num_backups -lt 2 ]; then 
  echo "Need at least two backup disks, found: $backup_disks"
  exit
fi

for disk_from in "${backup_disks[@]}"; do
  for disk_to in "${backup_disks[@]}"; do
    if [ $disk_from != $disk_to ]; then 
      echo "Dry run ${disk_from} -> ${disk_to}"
      read -n 1 -s

      rsync \
        --perms \
        --whole-file \
        --chmod=777 \
        --archive \
        --recursive \
        --stats \
        --human-readable \
        --exclude=".*" \
        --out-format="/%f" \
        --dry-run \
        $disk_from \
        $disk_to \
        | egrep -v "${disk_from}[^/]+/[^/]+/"  # Don't print all subfolders.

      read -p "Proceed ${disk_from} -> ${disk_to}? " -n 1 -r
      echo    # (optional) move to a new line

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rsync \
          --perms \
          --whole-file \
          --chmod=777 \
          --archive \
          --recursive \
          --stats \
          --human-readable \
          --exclude=".*" \
          --progress \
          --info=name0 \
          --info=progress2 \
          $disk_from \
          $disk_to
      fi

      echo -e "\n\n\n"
    fi
  done
done
