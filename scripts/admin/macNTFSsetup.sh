# THIS IS A REFERENCE SCRIPT. Copy and paste and run the following commands manually.
# re: https://www.howtogeek.com/236055/how-to-write-to-ntfs-drives-on-a-mac/

# re https://github.com/Homebrew/homebrew-php/issues/4527 -- also re a run of brew doctor
# sudo mkdir -p /usr/local/sbin
# sudo chown -R $(whoami) /usr/local/sbin

# brew install ntfs-3g

# sudo mkdir /Volumes/NTFS

# diskutil info /Volumes/DRIVENAME | grep UUID

# ~-~-~-~-
# NOTE FROM THAT THE PARTITION NAME e.g. disk0s3 for the partition you want to access e.g. BOOTCAMP 
# ~-~-~-~-

# sudo umount /dev/THAT_PARTITION_NAME
sudo /usr/local/bin/ntfs-3g /dev/THAT_PARTITION_NAME /Volumes/NTFS -olocal -oallow_other