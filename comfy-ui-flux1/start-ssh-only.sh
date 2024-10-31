#!/bin/bash

echo "pod started"

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

# Move text-generation-webui's folder to $VOLUME so models and all config will persist
/comfyui-on-workspace.sh

# Start nginx as reverse proxy to enable api access
service nginx start

huggingface-cli download --local-dir /opt/models/unet black-forest-labs/FLUX.1-dev --include 'flux1-dev.safetensors'
huggingface-cli download --local-dir /opt/models/vae/ae.safetensors black-forest-labs/FLUX.1-dev --include 'vae/diffusion_pytorch_model.safetensors'
wget -O /opt/models/clip/clip_l.safetensors "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true"
wget -O /opt/models/clip/t5xxl_fp16.safetensors "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
# Launch the UI
python3 /ComfyUI/main.py --listen --preview-method auto

sleep infinity
