echo "Dry run backup -> backup2"
rsync \
  --perms \
  --whole-file \
  --chmod=777 \
  --archive \
  --recursive \
  --progress \
  --info=name0 \
  --info=progress2 \
  --stats \
  --human-readable \
  --exclude=".*" \
  --out-format="%f" \
  --dry-run \
  /Volumes/backup/ \
  /Volumes/backup2/

read -p "Proceed backup -> backup2 ? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
rsync \
  --perms \
  --whole-file \
  --chmod=777 \
  --archive \
  --recursive \
  --progress \
  --info=name0 \
  --info=progress2 \
  --stats \
  --human-readable \
  --exclude=".*" \
  /Volumes/backup/ \
  /Volumes/backup2/
fi

echo "==========="
echo "==========="
echo "==========="
echo "Dry run backup2 -> backup"
rsync \
  --perms \
  --whole-file \
  --chmod=777 \
  --archive \
  --recursive \
  --progress \
  --info=name0 \
  --info=progress2 \
  --stats \
  --human-readable \
  --exclude=".*" \
  --out-format="%f" \
  --dry-run \
  /Volumes/backup2/ \
  /Volumes/backup/

read -p "Proceed backup2 -> backup ? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
rsync \
  --perms \
  --whole-file \
  --chmod=777 \
  --archive \
  --recursive \
  --progress \
  --info=name0 \
  --info=progress2 \
  --stats \
  --human-readable \
  --exclude=".*" \
  /Volumes/backup2/ \
  /Volumes/backup/
fi
