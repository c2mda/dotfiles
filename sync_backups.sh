#!/bin/bash
# To deduplicate large files first:
#
#   brew install jdupes
#   jdupes . --no-hidden --recurse --size -X size+:50m
#
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

backup_disks=( /Volumes/backup*/ )
num_backups=${#backup_disks[*]}
echo "Found ${num_backups} disks: ${backup_disks[*]}"

if [ "$num_backups" -lt 2 ]; then
  echo "Need at least two backup disks, found: ${backup_disks[*]}"
  exit
fi

function do_rclone(){
  # copy: Copy the source to the destination. Does not transfer files that are 
  #       identical on source and destination, testing by size and modification
  #       time or MD5SUM. Doesn't delete files from the destination.
  # --progress: show progress.
  # --exclude: ignore MacOS special files.
  # --ignore-checksum: Skip post copy check of checksums.
  # --metadata: If set, preserve metadata when copying objects.
  # --size-only: Skip based on size only, not modtime or checksum.
  # --transfers: Use only one transfer.
  rclone copy \
    --progress \
    --exclude ".**" \
    --ignore-checksum \
    --metadata \
    --size-only \
    --transfers 1 \
    "$@"
}

for disk_from in "${backup_disks[@]}"; do
  for disk_to in "${backup_disks[@]}"; do

    # Don't sync a disk with itself.
    if [[ "$disk_from" == "$disk_to" ]]; then
      continue
    fi

    # Dry run.
    read -p "Dry run ${disk_from} -> ${disk_to} ? (y) " -n 1 -r
    echo "y"   # Move to a new line.
    if ! [[ ${REPLY:-y} =~ ^[Yy]$ ]]; then
      continue
    fi

    do_rclone \
      --dry-run \
      "$disk_from" \
      "$disk_to"

    # Confirmation.
    read -p "Proceed ${disk_from} -> ${disk_to}? (y/n) " -n 1 -r
    echo "y"   # Move to a new line.
    if ! [[ ${REPLY:-y} =~ ^[Yy]$ ]]; then
      continue
    fi

    # Real run.
    do_rclone\
      "$disk_from" \
      "$disk_to"

    echo -e "\n\n\n"
  done
done
