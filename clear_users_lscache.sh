#!/bin/bash
################################################################################
#
# Collects user's old cache files which are older than 24h inside:
# /home/user/lscache directories and removes them to free up storage space
# in case there is not enough storage left in /home partition 
# 
# Author:  Vasiliy Dagdzhi
# e-mail:  ljnero8@gmail.com
# Date:    2022-12-11
# Version: 1.0.0
#
################################################################################

# collect all user's lscache folders which have at least over 1Mb or 1Gb of space inside:
large_folders_list=$(find /home -maxdepth 2 -name "lscache" -exec du -shx {} \;| grep -E "M|G" | awk '{print $2}')


# Print the number of such users are on the server
echo -e "\033[0;32mFound: $(echo -e "$large_folders_list" | wc -l)" "\t user's with large lscache folders.\n"

# list the users who own the large folders and print them
echo -e "\033[0;32m\nUser's list:"

for i in $large_folders_list;
do
  	awk -F/ '{print $3}' <<< "$i"
done;

# locate all files inside these folders which are older than 24h and remove them
# excluding: .cm.log files from the list

totalSize=0

for i in $large_folders_list;
do
	# calculate the size of files which are going to be removed
	allSizes=$(find "$i" ! -iname ".cm.log" -type f -mtime +1 -exec stat -c "%s" {} \;)
	for fileSize in $allSizes; do
    		totalSize=$(($totalSize + $fileSize))
	done
	
	# perform removal
  	find "$i" ! -iname ".cm.log" -type f  -mtime +1 -exec ls -lht {} \; # -exec rm -f {} \;
done;


echo  -e "$($totalSize/1024/1024/1024) GB - removed."
