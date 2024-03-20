![Logo](assets/cvte-logo.png)

# ClearVision@theEdge

This guide will walk you through the steps to create a Google Kubernetes Engine (GKE) cluster with NVIDIA GPUs and install the NVIDIA driver installer DaemonSet.

### Prerequisites

- [Device Setup Prerequsites](#setup-device-for-clearvisiontheedge)
- [GKE Cluster with Nvidia GPU Nodes](#create-a-gke-cluster-with-nvidia-gpu-nodes)

## Deploy ClearVision@theEdge 

To deploy ClearVision@theEdge, navigate to the ClearVision@theEdge directory. You will see an i7e folder that includes the configurations files to deploy. 

#### Configurations file 

ClearVision@theEdge directory is structured as a Helm chart, indicated by the presence of Chart.yaml, .helmignore, templates, and values.yaml files. 

The base configuration file is shown here:
[values.yaml](ClearVision@theEdge/i7e/values.yaml)

The values.yaml file contains configuration settings for the ClearVision@theEdge application, structured under the i7e key. Here are some of the important sections and parameters found within this file:

- image: Specifies the Docker image to use for the deployment, including the registry, repository, and tag.
- imagePullPolicy: Defines the policy for pulling the image, such as IfNotPresent which means the image will be pulled if it's not already present locally.
- hostNetwork: A boolean value indicating whether to use the host's network namespace.
- serviceAccountJSON: Can be used to specify a service account JSON file for authentication, currently set to null.
- gpuLimit: Indicates whether a GPU limit is applied, useful for workloads requiring GPU resources.
- cameras: An array that could be used to configure camera inputs, currently empty.
- config: Contains further configuration settings, which might include custom application settings, performance tuning parameters, or environment-specific overrides.


#### Deploy 

To deploy the base app from the ClearVision@theEdge:

```bash 
helm install i7e-pipeline i7e/ -f values.yaml
```

## Create a GKE Cluster with NVIDIA GPU Nodes

1. Set up your environment

Ensure your `gcloud` tool is authenticated and set to the correct project:

```bash
gcloud auth login
gcloud config set project [YOUR_PROJECT_ID]
```

2. Enable the required GCP APIs
```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

3. Create a GKE cluster
Create a cluster with NVIDIA Tesla T4 GPUs, you may use any nvidia GPUs. Adjust the zone and machine type as needed:

```bash 
gcloud container clusters create [CLUSTER_NAME] \
  --zone [COMPUTE_ZONE] \
  --machine-type n1-standard-4 \
  --accelerator type=nvidia-tesla-t4,count=1 \
  --num-nodes 1 \
  --enable-autoupgrade
```

4. Verify the cluster creation:
```bash
gcloud container clusters list
```

## Install NVIDIA Drivers on GKE Nodes

You must manually install a compatible NVIDIA GPU driver on the nodes. Google provides a DaemonSet that you can apply to install the drivers. On GPU nodes that use Container-Optimized OS, you also have the option of selecting between the default GPU driver version or a newer version.

To deploy the installation DaemonSet and install the default GPU driver version, run the following command:

- If on a Container-Optimized OS (COS) 
```bash
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded-latest.yaml
```

- If on an Ubuntu Node
```bash
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/ubuntu/daemonset-preloaded.yaml
```

NOTE:
For NVIDIA L4 GPUs, install the R525 driver instead by using the following command:
```bash
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/ubuntu/daemonset-preloaded-R525.yaml
```

## Verify Nvidia Cuda Runtime on Kubernetes

To find this information on your own machine you usually use nvidia-smi, so to do this on Kubernetes you can create a pod that runs nvidia-smi and check the logs to see its output.

```bash
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-version-check
spec:
  restartPolicy: OnFailure
  containers:
  - name: nvidia-version-check
    image: "nvidia/cuda:11.0.3-base-ubuntu20.04"
    command: ["nvidia-smi"]
    resources:
      limits:
         nvidia.com/gpu: "1"
EOF
```

View the logs 
```bash
kubectl logs nvidia-version-check
```

The output shoould look like this
```bash
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 495.46       Driver Version: 495.46       CUDA Version: 11.5     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Quadro RTX 8000     Off  | 00000000:15:00.0 Off |                  Off |
| 33%   29C    P8    16W / 260W |      5MiB / 48601MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
+-----------------------------------------------------------------------------+
```

You can clear up the containers with 
```bash
kubectl delete pod nvidia-version-check
```

## Setup device for ClearVision@theEdge

### Install the Latest Gcloud CLI

Follow the steps given in Install the gcloud CLI  

```bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli
```

### Install the latest Nvidia Drivers and CUDA

```bash
sudo systemctl stop google-cloud-ops-agent
curl https://raw.githubusercontent.com/GoogleCloudPlatform/compute-gpu-installation/main/linux/install_gpu_driver.py --output install_gpu_driver.py
sudo python3 install_gpu_driver.py
```
Verify with ```nvidia-smi```, if you see an output, continue with 

```bash
sudo apt install nvidia-cuda-toolkit
```

Verify with ```nvcc --version```

### Install Docker with Nvidia Container Runtime

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

#### Docker installation

```bash 
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### Nvidia Container Toolkit installation:

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```
##### Configuring containerd (for Kubernetes)
Configure the container runtime by using the nvidia-ctk command:

```bash
sudo nvidia-ctk runtime configure --runtime=containerd
```
The nvidia-ctk command modifies the /etc/containerd/config.toml file on the host. The file is updated so that containerd can use the NVIDIA Container Runtime.

Restart containerd:
```bash
sudo systemctl restart containerd
```

#### Enable the Google Kubernetes Engine API and Install kubectl

```bash
grep -rhE ^deb /etc/apt/sources.list* | grep "cloud-sdk"
apt-get update
apt-get install -y kubectl
```
Verify with ```kubectl version --client```

Install the gke-gcloud-auth-plugin binary:
```bash
apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```

#### Install helm and k9s

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

```bash
snap install k9s --devmode
```


