# install gcloud ref: https://cloud.google.com/sdk/docs/quickstart
 mv ~/Downloads/google-cloud-sdk-340.0.0-darwin-arm.tar.gz ~/
 tar -xvf google-cloud-sdk-340.0.0-darwin-arm.tar.gz
 ./google-cloud-sdk/install.sh
 ./google-cloud-sdk/bin/gcloud init

# instance management
gcloud compute instances start tf-exp

# connect to remote instance
gcloud compute ssh tf-exp

# install deps for deeplab
sudo apt-get update
sudo apt install python3-dev python3-pip python3-venv
python3 -m venv --system-site-packages ./tf-env
source ./tf-env/bin/activate
pip install --upgrade pip   
pip install tensorflow==1.15
git clone --depth=1 https://github.com/tensorflow/models.git

pip install matplotlib numpy pillow tf_slim
cd ~/models/research
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# run sample run of training
cd deeplab
bash local_test.sh


# track logs on tensorboard
tensorboard --logdir=/home/akshit/models/research/deeplab/datasets/pascal_voc_seg/exp/train_on_trainval_set/train

# to view tensorboard results, ref: https://www.montefischer.com/2020/02/20/tensorboard-with-gcp.html
gcloud compute ssh tf-exp -- -NfL 6006:localhost:6006

