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
# install gpu drivers 
# tf 1.15 has been tested on cuda 10.0 https://www.tensorflow.org/install/source#linux
# compatible nvidia driver version CUDA 10.0 (10.0.130)	>= 410.48 ref: https://docs.nvidia.com/deploy/cuda-compatibility/index.html#binary-compatibility__table-toolkit-driver
# minimum recommended for T4 by gcp is 10.1 ref: https://cloud.google.com/compute/docs/gpus/install-drivers-gpu#nvidia_driver_cuda_toolkit_and_cuda_runtime_versions
# install instructions for cuda 10.1: https://docs.nvidia.com/cuda/archive/10.1/cuda-installation-guide-linux/index.html#about-this-document
# install gcc ref: https://linuxize.com/post/how-to-install-gcc-compiler-on-ubuntu-18-04/
sudo apt install build-essential

# remove previous version of cuda(didn't worked)
sudo apt-get remove --auto-remove cuda
sudo apt-get --purge -y remove 'cuda*'
sudo apt-get --purge -y remove 'nvidia*'
apt-key list
sudo rm -rf /etc/apt/trusted.gpg
sudo rm -rf /etc/apt/sources.list.d/cuda.list





# install cuda 10.0 ref: https://developer.nvidia.com/cuda-10.0-download-archive?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=1804&target_type=deblocal
wget https://developer.download.nvidia.com/compute/cuda/10.0/secure/Prod/local_installers/cuda-repo-ubuntu1804-10-0-local-10.0.130-410.48_1.0-1_amd64.deb?-EUxJapJw8IYOaC4bS8U0dwhnKuMvVMgYd7OJkHlQOIxS18ldHSS32Dmr7lT4kGfFKAjxxZM13YdHcSMfJYVLUKQHiDBAvLVlE_VInUGQUJhHbKW5nRbIpSAPztBNu_a0JqQIl4Dd96nYeHlN82AKwpcg6xFi524oi46aF5_TbgOqC31FZif8X7fMZ-k2dW560BJFIwnvPziCEyw1kgef98G5yCDmeq6g7vL5wg
sudo dpkg -i cuda-repo-ubuntu1804-10-0-local-10.0.130-410.48_1.0-1_amd64.deb
sudo apt-key add /var/cuda-repo-10-0-local-10.0.130-410.48/7fa2af80.pub
sudo apt-get update
sudo apt-get install cuda
sudo reboot











sudo apt install python3-dev python3-pip python3-venv
python3 -m venv --system-site-packages ./tf-env
source ./tf-env/bin/activate
pip install --upgrade pip   
pip install tensorflow-gpu==1.15
git clone --depth=1 https://github.com/akshit-protonn/models.git
pip install matplotlib numpy pillow tf_slim
cd ~/models/research
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# run sample run of training
cd deeplab
bash local_test.sh


# track logs on tensorboard
tensorboard --logdir=/home/akshit/models/research/deeplab/datasets/photo_matte_85/exp/train_on_train_set_mobilenetv2/train/

# to view tensorboard results, ref: https://www.montefischer.com/2020/02/20/tensorboard-with-gcp.html
gcloud compute ssh tf-gpu-vm -- -NfL 6006:localhost:6006

# prepare and push photomatte dataset
mkdir -p ~/models/research/deeplab/datasets/photo_matte_85
cd /Users/akshit/repos/tensorflow_models/research/deeplab/data
zip -r PhotoMatte85.zip ./PhotoMatte
gcloud compute scp PhotoMatte85.zip tf-gpu-vm:~/models/research/deeplab/datasets/photo_matte_85/
cd ~/models/research/deeplab/datasets/photo_matte_85
sudo apt install unzip
unzip PhotoMatte85.zip

gcloud compute scp datasets/build_photomatte_data.py datasets/convert_photomatte85.sh tf-exp:~/models/research/deeplab/datasets/ 
# vscode remote development 
# ref: https://cloud.google.com/sdk/gcloud/reference/compute/config-ssh#--dry-run
# https://code.visualstudio.com/docs/remote/ssh
gcloud compute config-ssh
tf-exp.asia-south1-c.arched-medley-313509

rsync -arvm --include-from=/Users/akshit/repos/tensorflow_models/research/deeplab/remote_sync_include.conf \
/Users/akshit/repos/tensorflow_models/research/deeplab \
tf-gpu-vm.us-central1-c.arched-medley-313509:/home/akshit/models/research

rm -r /home/akshit/models/research/deeplab/datasets/photo_matte_85/exp/train_on_train_set_mobilenetv2/train

# create tf-gpu instance
gcloud beta compute --project=arched-medley-313509 instances create tf-gpu --zone=us-central1-c --machine-type=n1-standard-2 --subnet=default --network-tier=PREMIUM --maintenance-policy=TERMINATE --service-account=89227916866-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --accelerator=type=nvidia-tesla-t4,count=1 --tags=http-server,https-server --image=ubuntu-1804-bionic-v20210514 --image-project=ubuntu-os-cloud --boot-disk-size=30GB --boot-disk-type=pd-balanced --boot-disk-device-name=tf-gpu --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

