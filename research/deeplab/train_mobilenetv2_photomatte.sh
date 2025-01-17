#!/bin/bash
# Copyright 2018 The TensorFlow Authors All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# This script is used to run local test on PhotoMatte85 using MobileNet-v2.
# Users could also modify from this script for their use case.
#
# Usage:
#   # From the tensorflow/models/research/deeplab directory.
#   sh ./train_mobilenetv2_photomatte.sh 
#
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Move one-level up to tensorflow/models/research directory.
cd ..

# Update PYTHONPATH.
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Set up the working environment.
CURRENT_DIR=$(pwd)
WORK_DIR="${CURRENT_DIR}/deeplab"

# Go to datasets folder and convert PhotoMatte segmentation dataset.
DATASET_DIR="datasets"
cd "${WORK_DIR}/${DATASET_DIR}"
# sh convert_photomatte85.sh

# Go back to original directory.
cd "${CURRENT_DIR}"

# Set up the working directories.
PHOTOMATTE_FOLDER="photo_matte_85"
EXP_FOLDER="exp/train_on_train_set_mobilenetv2"
INIT_FOLDER="${WORK_DIR}/${DATASET_DIR}/${PHOTOMATTE_FOLDER}/init_models"
TRAIN_LOGDIR="${WORK_DIR}/${DATASET_DIR}/${PHOTOMATTE_FOLDER}/${EXP_FOLDER}/train"
EVAL_LOGDIR="${WORK_DIR}/${DATASET_DIR}/${PHOTOMATTE_FOLDER}/${EXP_FOLDER}/eval"
VIS_LOGDIR="${WORK_DIR}/${DATASET_DIR}/${PHOTOMATTE_FOLDER}/${EXP_FOLDER}/vis"
EXPORT_DIR="${WORK_DIR}/${DATASET_DIR}/${PHOTOMATTE_FOLDER}/${EXP_FOLDER}/export"
mkdir -p "${INIT_FOLDER}"
mkdir -p "${TRAIN_LOGDIR}"
mkdir -p "${EVAL_LOGDIR}"
mkdir -p "${VIS_LOGDIR}"
mkdir -p "${EXPORT_DIR}"

# Copy locally the trained checkpoint as the initial checkpoint.
TF_INIT_ROOT="http://download.tensorflow.org/models"
CKPT_NAME="deeplabv3_mnv2_pascal_train_aug"
TF_INIT_CKPT="${CKPT_NAME}_2018_01_29.tar.gz"
cd "${INIT_FOLDER}"
wget -nd -c "${TF_INIT_ROOT}/${TF_INIT_CKPT}"
tar -xf "${TF_INIT_CKPT}"
cd "${CURRENT_DIR}"

PHOTOMATTE_DATASET="${WORK_DIR}/${DATASET_DIR}/${PHOTOMATTE_FOLDER}/tfrecord"

# train on pretrained ms_coco weights
NUM_ITERATIONS=1000
# python "${WORK_DIR}"/train.py \
#   --logtostderr \
#   --train_split="train" \
#   --model_variant="mobilenet_v2" \
#   --output_stride=16 \
#   --train_crop_size="513,513" \
#   --log_steps=10 \
#   --train_batch_size=4 \
#   --training_number_of_steps="${NUM_ITERATIONS}" \
#   --save_summaries_images=true \
#   --fine_tune_batch_norm=true \
#   --save_summaries_secs=60 \
#   --train_logdir="${TRAIN_LOGDIR}" \
#   --tf_initial_checkpoint="${INIT_FOLDER}/${CKPT_NAME}/model.ckpt-30000" \
#   --initialize_last_layer=false \
#   --dataset="photo_matte_85" \
#   --dataset_dir="${PHOTOMATTE_DATASET}"

# python "${WORK_DIR}"/eval.py \
#   --logtostderr \
#   --eval_split="train" \
#   --model_variant="mobilenet_v2" \
#   --eval_crop_size="513,513" \
#   --checkpoint_dir="${TRAIN_LOGDIR}" \
#   --eval_logdir="${EVAL_LOGDIR}" \
#   --dataset="photo_matte_85" \
#   --min_resize_value=513 \
#   --max_resize_value=513 \
#   --dataset_dir="${PHOTOMATTE_DATASET}" \
#   --max_number_of_evaluations=1

# Visualize the results.
python "${WORK_DIR}"/vis.py \
  --logtostderr \
  --vis_split="train" \
  --model_variant="mobilenet_v2" \
  --vis_crop_size="513,513" \
  --dataset="photo_matte_85" \
  --min_resize_value=513 \
  --max_resize_value=513 \
  --checkpoint_dir="${TRAIN_LOGDIR}" \
  --vis_logdir="${VIS_LOGDIR}" \
  --dataset_dir="${PHOTOMATTE_DATASET}" \
  --max_number_of_iterations=1

# # Export the trained checkpoint.
# CKPT_PATH="${TRAIN_LOGDIR}/model.ckpt-${NUM_ITERATIONS}"
# EXPORT_PATH="${EXPORT_DIR}/frozen_inference_graph.pb"

# python "${WORK_DIR}"/export_model.py \
#   --logtostderr \
#   --checkpoint_path="${CKPT_PATH}" \
#   --export_path="${EXPORT_PATH}" \
#   --model_variant="mobilenet_v2" \
#   --num_classes=21 \
#   --crop_size=513 \
#   --crop_size=513 \
#   --inference_scales=1.0

# Run inference with the exported checkpoint.
# Please refer to the provided deeplab_demo.ipynb for an example.
