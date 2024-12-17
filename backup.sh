#!/bin/bash
#Check if there is a backup directory
if [ ! -d "$HOME/backups" ]; then
     mkdir -p "$HOME/backups/reports"
fi

#Create hash and archive of /etc in the backup directory
sudo find /etc -type f | sudo xargs md5sum > $HOME/backups/backups.txt
sudo tar czf $HOME/backups/etc_backup.tar.gz /etc
