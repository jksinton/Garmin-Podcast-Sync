#!/bin/bash

MTP_DIR=/run/user/1000/gvfs/mtp:host=091e_4b54_0000ed6c2317
PODCAST_DIR=/home/`whoami`/Podcasts/
DOWNLOADS_DIR=/home/`whoami`/gPodder/Downloads/
PLAYLIST=/home/`whoami`/Podcasts/Podcasts.m3u8

# Downloading any new episodes
echo "Downloading any new podcast episodes using gPodder"
gpo update
gpo download

# sync gPodder folders
echo 
echo "Syncying gPodder folders"
find ${DOWNLOADS_DIR} -mindepth 1 -type d -print0 |  xargs --null -I {} rsync -av --exclude="folder.jpg" --link-dest={}/ {}/ $PODCAST_DIR

# remove podcasts older than 2 weeks from the source directory
echo 
echo "Removing podcasts older than 2 weeks from source directory"
find ~/Podcasts -type f -mtime +14 -name '*mp3' -print0 | xargs -r0 rm -v --

# create playlist file
echo 
echo "Creating playlist"
cd ${PODCAST_DIR}
ls -t *mp3 | sed 's/^/Podcasts\//' > ${PLAYLIST}

# Syncing podcasts to fenix
echo
echo "Transferring podcasts to Fenix"
sync_files=/tmp/fenix-sync-files.log
src=${PODCAST_DIR}
dest=${MTP_DIR}/Primary/Podcasts/
options="-n --omit-dir-times --no-perms --recursive --inplace --size-only"
rsync ${options} --out-format="%n" --exclude=".*" ${src} ${dest} > ${sync_files}
cat ${sync_files}
xargs -a ${sync_files} -d '\n' -I {} gio copy -p {} ${MTP_DIR}/Primary/Podcasts/.

# Removing old podcasts from fenix
echo
echo "Removing old podcasts from Fenix"
delete_files=/tmp/fenix-delete-files.log
options_delete="-n  --omit-dir-times --no-perms --recursive --inplace --size-only --delete"
rsync ${options_delete} --out-format="%n" --exclude=".*" ${src} ${dest} | grep deleting | sed 's/deleting //' > ${delete_files}
cat ${delete_files}
xargs -a ${delete_files} -d '\n' -I {} gio remove ${MTP_DIR}/Primary/Podcasts/{}
