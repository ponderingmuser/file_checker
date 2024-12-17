#!/bin/bash

#Hash /etc, check hash against first hash.
sudo find /etc -type f | sudo xargs md5sum > $HOME/backups/check.txt

#Format the diff output. Removes files that end with '-'. Just reference file names. Then remove the trailing / to reference the archive. Write the results to text for further processing. 
output=$(diff $HOME/backups/backups.txt $HOME/backups/check.txt | grep -v '\-$' | awk '/^[<>]/ {print $3}' | sort -u | cut -c 2- | tee $HOME/backups/changes.txt)
if [ -z "$output" ]; then
    echo "No changes detected."
    rm $HOME/backups/changes.txt
    exit 0
else
    for file in $(cat $HOME/backups/changes.txt); do
    echo "/$file" >> $HOME/backups/diff.txt

    # Check if file exists in the archive and filesystem
    if tar -tzf $HOME/backups/etc_backup.tar.gz "$file" >/dev/null 2>&1; then
        # File exists in the archive
        if [ -e "/$file" ]; then
            # File exists in the filesystem: Compare for modification
            sudo bash -c "diff <(tar -xOzf $HOME/backups/etc_backup.tar.gz $file) /$file >> $HOME/backups/diff.txt"
        else
            # File does not exist in the current filesystem: Deleted
            echo "DELETED: /$file" >> $HOME/backups/diff.txt
        fi
    else
        # File does not exist in the archive: Added
        echo "ADDED: /$file" >> $HOME/backups/diff.txt
    fi

    echo >> $HOME/backups/diff.txt
    done
fi

# Display the results
rm $HOME/backups/changes.txt
rm $HOME/backups/check.txt
cat $HOME/backups/diff.txt
mv $HOME/backups/diff.txt $HOME/backups/reports/report.$(date +"%F-%H-%M").txt
