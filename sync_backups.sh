#!/bin/bash
# Note that % progress, transfer speed and estimated time left are incorrect,
# because rsync does not know ahead of time which files will be copied in
# recursive mode.
#
# But you can see total transfer size in the dry run, and current transferred
# size during the actual run.
#
# To deduplicate large files first:
#
#   brew install jdupes
#   jdupes . --no-hidden --recurse --size -X size+:50m
#
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
    read -p "Dry run ${disk_from} -> ${disk_to} ? (Y/y)" -n 1 -r
    echo    # Move to a new line.
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
      continue
    fi

    # --perms: preserve permissions.
    # --recursive: copy subfolders.
    # --times: preserve times.
    # --whole-file: files are transferred whole, not delta.
    # --stats: print stats at the end (number/size/etc).
    rsync \
      --perms \
      --recursive \
      --times \
      --whole-file \
      --chmod=777 \
      --stats \
      --human-readable \
      --exclude=".*" \
      --out-format="/%f" \
      --dry-run \
      $disk_from \
      $disk_to \
      | egrep -v "${disk_from}[^/]+/[^/]+/"  # Don't print subfolders.

    # Confirmation.
    read -p "Proceed ${disk_from} -> ${disk_to}? (Y/y)" -n 1 -r
    echo    # Move to a new line.
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
      continue
    fi

    # Real run.
    # --no-inc-recursive: build full file list first, for exact total progress.
    # --info=name0: don't display current name.
    # --info=progress2: accurate total progress.
    rsync \
      --perms \
      --recursive \
      --times \
      --whole-file \
      --no-inc-recursive \
      --chmod=777 \
      --stats \
      --human-readable \
      --exclude=".*" \
      --info=name0 \
      --info=progress2 \
      $disk_from \
      $disk_to

    echo -e "\n\n\n"
  done
done
