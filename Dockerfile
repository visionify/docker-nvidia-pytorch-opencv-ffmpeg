FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

ARG CUDA_VERSION=11.3.0

LABEL maintainer="https://github.com/visionify"

ARG PYTHON_VERSION=3.8

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

# https://techoverflow.net/2019/05/18/how-to-fix-configuring-tzdata-interactive-input-when-building-docker-images/
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Mountain

# ENV LD_LIBRARY_PATH /usr/local/${CUDA}/compat:$LD_LIBRARY_PATH

RUN apt-get update -qq --fix-missing && \
    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get install -y python${PYTHON_VERSION} python3-pip python3-dev

ENV PYTHONPATH="/usr/lib/python${PYTHON_VERSION}/site-packages:/usr/local/lib/python${PYTHON_VERSION}/site-packages"

RUN CUDA_PATH=(/usr/local/cuda-*) && \
    CUDA=`basename $CUDA_PATH` && \
    echo "$CUDA_PATH/compat" >> /etc/ld.so.conf.d/${CUDA/./-}.conf && \
    ldconfig

# Install all dependencies for OpenCV
RUN apt-get -y update -qq --fix-missing && \
    apt-get -y install --no-install-recommends \
        unzip \
        cmake \
        pkg-config \
        apt-utils \
        build-essential \
        gfortran \
        qt5-default \
        checkinstall \
        ffmpeg \
        libtbb2 \
        libopenblas-base \
        libopenblas-dev \
        liblapack-dev \
        libatlas-base-dev \
        #libgtk-3-dev \
        #libavcodec58 \
        libavcodec-dev \
        #libavformat58 \
        libavformat-dev \
        libavutil-dev \
        #libswscale5 \
        libswscale-dev \
        libjpeg8-dev \
        libpng-dev \
        libtiff5-dev \
        #libdc1394-22 \
        libdc1394-22-dev \
        libxine2-dev \
        libv4l-dev \
        libgstreamer1.0 \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-0 \
        libgstreamer-plugins-base1.0-dev \
        libglew-dev \
        libpostproc-dev \
        libeigen3-dev \
        libtbb-dev \
        zlib1g-dev \
        libsm6 \
        libxext6 \
        libxrender1 \
        wget \
        vim \
        python-is-python3

# Install gstreamer
RUN apt-get install --no-install-recommends -y \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools \
    gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 gstreamer1.0-pulseaudio

# Install OpenCV
RUN pip install numpy opencv-python opencv-contrib-python

# Install torch.
RUN pip install torch torchvision torchaudio

# Install python requirements
RUN pip install mediapipe nvidia-ml-py3 vidgear[asyncio] seaborn
RUN pip install pyyaml coloredlogs python-dotenv singleton_decorator
RUN pip install aiohttp requests redis
RUN pip install pafy youtube_dl yt_dlp vidgear

# Install missing apt packages
RUN apt-get install --no-install-recommends -y \
    python-is-python3 git

# Print version info
RUN ffmpeg -version && \
    gst-launch-1.0 --gst-version && \
    python -c "import cv2; print(cv2.getBuildInformation())" && \
    python -c "import cv2; print('cv2: ' + cv2.__version__)" && \
    python -c "import torch; print('torch: ' + torch.__version__)"
