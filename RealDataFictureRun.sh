#!/bin/bash

# check if the number of arguments is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_directory>"
    exit 1
fi

# assign the input path from the command-line argument
path=$1

# data specific setup
mu_scale=1 # 1 if your data's coordinates are already in micrometer
key=Count
MJ=Y # if your data is sorted by the Y-axis
env=/mnt/scratch1/miniconda3/envs/ficture
gitpath=/mnt/scratch1/Luke/FICTURE/ficture # path to this repository

# create pixel minibatches
input=${path}/transcripts.tsv.gz
output=${path}/batched.matrix.tsv.gz
/mnt/scratch1/Luke/FICTURE/ficture/examples/script/generic_I.sh input=${input} output=${output} MJ=${MJ} env=${env} gitpath=${gitpath}

# parameters for initializing the model
nFactor=12 # number of factors
sliding_step=2
train_nEpoch=3
train_width=12 # \sqrt{3} x the side length of the hexagon (um)
model_id=nF${nFactor}.d_${train_width} # an identifier kept in output file names
min_ct_per_feature=20 # ignore genes with total count \< 20
R=10 # we use R random initializations and pick one to fit the full model
thread=4 # number of threads to use
feature=${path}/feature.clean.tsv.gz

# parameters for pixel level decoding
fit_width=12 # often equal or smaller than train_width (um)
anchor_res=4 # distance between adjacent anchor points (um)
radius=$(($anchor_res+1))
anchor_info=prj_${fit_width}.r_${anchor_res} # an identifier
coor=${path}/coordinate_minmax.tsv

# prepare training minibatches
input=${path}/transcripts.tsv.gz
hexagon=${path}/hexagon.d_${train_width}.tsv.gz
/mnt/scratch1/Luke/FICTURE/ficture/examples/script/generic_II.sh env=${env} gitpath=${gitpath} key=${key} mu_scale=${mu_scale} major_axis=${MJ} path=${path} input=${input} output=${hexagon} width=${train_width} sliding_step=${sliding_step}

# model training
/mnt/scratch1/Luke/FICTURE/ficture/examples/script/generic_III.sh env=${env} gitpath=${gitpath} key=${key} mu_scale=${mu_scale} major_axis=${MJ} path=${path} pixel=${input} hexagon=${hexagon} feature=${feature} model_id=${model_id} train_width=${train_width} nFactor=${nFactor} R=${R} train_nEpoch=${train_nEpoch} fit_width=${fit_width} anchor_res=${anchor_res} min_ct_per_feature=${min_ct_per_feature}

# pixel level decoding & visualization
/mnt/scratch1/Luke/FICTURE/ficture/examples/script/generic_V.sh env=${env} gitpath=${gitpath} key=${key} mu_scale=${mu_scale} path=${path} model_id=${model_id} anchor_info=${anchor_info} radius=${radius} coor=${coor}

echo "FICTURE Run Complete"