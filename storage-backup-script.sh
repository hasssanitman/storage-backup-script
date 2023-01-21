#!/bin/sh
# Storage backup script
# Copyright (c) 2023 Hasssanitman
# This script is licensed under GNU GPL version 2.0 or above
# ---------------------------------------------------------------------

### System Setup ###
BACKUP=/root/backup/storage # Or put your backup directory
ROOTDIRECTORY=/var/www/html # Or put your root directory
THESTORAGE=storage          # Or put your storage directory name
DATE=$(date +"%d-%b-%Y")

### FTP server Setup ###
FTPD="ftp-directory" # Put your FTP directory here
FTPU="ftp-user"      # Put your FTP username here
FTPP="ftp-password"  # Put your FTP password here
FTPS="ftp-address"   # Put your FTP address here

### Binaries ###
TAR="$(which tar)"
FTP="$(which ftp)"

### Today + hour ###
NOW=$(date +"%d%H")

### Create hourly dir ###
mkdir $BACKUP/$NOW
cd $ROOTDIRECTORY

for dir in */; do
cd $dir
if test -d ./$THESTORAGE; then
DIR="${PWD##*/}"
tar -zcvf $THESTORAGE-$DIR.tar.gz ./$THESTORAGE
mv $THESTORAGE-$DIR.tar.gz $BACKUP/$NOW
fi
cd ..
done

### Compress all Storages in one file to upload ###
ARCHIVE=$BACKUP/$NOW.tar.gz
ARCHIVED=$BACKUP/$NOW

$TAR -czvf $ARCHIVE $ARCHIVED

### Dump backup using FTP ###
cd $BACKUP
DUMPFILE=$NOW.tar.gz
$FTP -ivndp $FTPS <<END_SCRIPT
quote USER $FTPU
quote PASS $FTPP

mkdir $FTPD/$DATE
cd $FTPD/$DATE
mkdir $THESTORAGE
cd $THESTORAGE
binary
mput $DUMPFILE
quit
END_SCRIPT


### Delete the backup dir and keep archive ###
rm -rf $ARCHIVED