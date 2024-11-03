ARG CUDA_VERSION="12.1.1"
ARG CUDNN_VERSION="8"
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=nvidia/cuda:$CUDA_VERSION-cudnn$CUDNN_VERSION-devel-ubuntu$UBUNTU_VERSION

# Base NVidia CUDA Ubuntu image
FROM $DOCKER_FROM
ENV DEBIAN_FRONTEND=noninteractive 
ENV DEBCONF_NONINTERACTIVE_SEEN=true

COPY preseed.txt /tmp/preseed.txt

RUN debconf-set-selections /tmp/preseed.txt
# Install Python plus openssh, which is our minimum set of required packages.
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv python-is-python3 openssh-server openssh-client git git-lfs wget nano file ffmpeg libsm6 libxext6 gcc libc-ares2 libzen0v5 tmux net-tools curl nginx python3-tk && \
    python3 -m pip install --upgrade pip uv && \
    apt autoremove -y && \
    apt autoclean

RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

RUN wget https://mega.nz/linux/repo/xUbuntu_22.04/amd64/megacmd-xUbuntu_22.04_amd64.deb && \
    apt install "./megacmd-xUbuntu_22.04_amd64.deb" -y && \
    rm -rf "./megacmd-xUbuntu_22.04_amd64.deb"


# Copy the 'default' configuration file to the appropriate location
COPY default /etc/nginx/sites-available/default

ENV PATH="/usr/local/cuda/bin:${PATH}"

# Install pytorch
ARG PYTORCH="2.4.0"
ARG CUDA="121"
RUN pip3 install --no-cache-dir -U torch==$PYTORCH torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$CUDA
RUN pip3 install huggingface

COPY --chmod=755 start-ssh-only.sh /start.sh
COPY --chmod=755 comfyui-on-workspace.sh /comfyui-on-workspace.sh
COPY --chmod=755 civit.sh /civit_downloader.sh

# Clone the git repo and install requirements in the same RUN command to ensure they are in the same layer
# RUN cd /opt/ && \
#     git clone https://github.com/ostris/ai-toolkit.git && \
#     cd /opt/ai-toolkit && \
#     git submodule update --init --recursive 

RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    pip3 install -r requirements.txt && \
    cd custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    cd /ComfyUI && \
    mkdir pysssss-workflows && \
    mkdir -p /opt/models/clip && \
    mkdir -p /opt/models/vae && \
    mkdir -p /opt/models/unet && \
    rm -rf /etc/nginx/nginx.conf

COPY --chmod=755 txt2img.json /ComfyUI/user/default/workflows/txt2img.json
COPY --chmod=755 img2img.json /ComfyUI/user/default/workflows/img2img.json
COPY --chmod=755 LoRa.json /ComfyUI/user/default/workflows/LoRa.json
COPY --chmod=755 SchedulerSampler.json /ComfyUI/user/default/workflows/SchedulerSampler.json
COPY --chmod=755 extra_model_paths.yaml /ComfyUI/exta_model_paths.yaml
COPY --chmod=755 comfy.settings.json /ComfyUI/user/default/comfy.settings.json

WORKDIR /workspace

EXPOSE 8188

# Due to the fact that the models are in a gated repository, we need to download them separately BEFORE building this image and store them locally in a folder called flux
# https://huggingface.co/black-forest-labs/FLUX.1-dev/blob/main/ae.safetensors
#COPY flux/ae.safetensors /opt/models/
# https://huggingface.co/black-forest-labs/FLUX.1-dev/blob/main/flux1-dev.safetensors
#COPY flux/flux1-dev.safetensors /opt/models/


COPY nginx.conf /etc/nginx/nginx.conf

CMD [ "/start.sh" ]
