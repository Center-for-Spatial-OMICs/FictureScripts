#!/bin/bash

# read file line by line and populate the array
mapfile -t file_array < /mnt/scratch1/Luke/FICTURE/XeniumRunAll/directory_felipe.txt

# specify where all Ficture files are going to be located in
target_dir="/mnt/scratch1/Luke/FICTURE/XeniumRunAll/"

# initialize an array of output paths
new_dir_array=()

# loop through the array and print each element
for element in "${file_array[@]}"; do
    IFS='/' read -ra parts <<< "$element"
    last_part="${parts[-1]}"
    new_dir=$target_dir$last_part
    mkdir -p "$new_dir"
    new_dir_array+=("$new_dir")
done

for ((i=0; i<${#new_dir_array[@]}; i++)); do
    echo "${new_dir_array[i]}"
    python /mnt/scratch1/Luke/FICTURE/XeniumRunAll/XeniumFileConverter.py ${file_array[i]} ${new_dir_array[i]}
    /mnt/scratch1/Luke/FICTURE/XeniumRunAll/RealDataFictureRun.sh ${new_dir_array[i]}
done

