#!/bin/bash
set -e

backup_disks=( /Volumes/backup*/ )
num_backups=${#backup_disks[*]}
echo "Found ${num_backups} disks: ${backup_disks[@]}"

if [ $num_backups -lt 2 ]; then 
  echo "Need at least two backup disks, found: $backup_disks"
  exit
fi

for disk_from in "${backup_disks[@]}"; do
  for disk_to in "${backup_disks[@]}"; do

    # Don't sync a disk with itself.
    if [[ $disk_from == $disk_to ]]; then 
      continue
    fi

    # Dry run.
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
      | egrep -v "${disk_from}[^/]+/[^/]+/"  # Don't print subfolders.

    # Confirmation.
    read -p "Proceed ${disk_from} -> ${disk_to}? " -n 1 -r
    echo    # Move to a new line.

    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
      continue
    fi

    # Real run.
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

    echo -e "\n\n\n"
  done
done
