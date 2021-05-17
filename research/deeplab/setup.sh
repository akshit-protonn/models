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

# prepare and push photomatte dataset
mkdir ~/models/research/deeplab/datasets/photo_matte_85
cd /Users/akshit/repos/tensorflow_models/research/deeplab/data
zip -r PhotoMatte85.zip ./PhotoMatte
gcloud compute scp PhotoMatte85.zip tf-exp:~/models/research/deeplab/datasets/photo_matte_85/
cd ~/models/research/deeplab/datasets/photo_matte_85
unzip PhotoMatte85.zip

gcloud compute scp datasets/build_photomatte_data.py datasets/convert_photomatte85.sh tf-exp:~/models/research/deeplab/datasets/ 
# vscode remote development 
# ref: https://cloud.google.com/sdk/gcloud/reference/compute/config-ssh#--dry-run
# https://code.visualstudio.com/docs/remote/ssh
gcloud compute config-ssh
tf-exp.asia-south1-c.arched-medley-313509

rsync -arvm --include-from=remote_sync_include.conf \
/Users/akshit/repos/tensorflow_models/research/deeplab \
tf-exp.asia-south1-c.arched-medley-313509:/home/akshit/models/research

rsync -arvm --include-from=remote_sync_include.conf \
/Users/akshit/repos/tensorflow_models/research/deeplab \
tf-exp.asia-south1-c.arched-medley-313509:/home/akshit