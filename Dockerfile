FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu16.04

ARG PYTHON_VERSION=3.6.9

# configurations for conda dependencies, and jupyter notebook respectively
COPY ./env/environment.yml /
COPY ./env/jupyter_notebook_config.py /root/.jupyter/

# get basic packages for debian
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         tmux \
         libjpeg-dev \
         libpng-dev && \
     rm -rf /var/lib/apt/lists/*

# Install conda, active base conda environment & install python
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
     echo "conda activate base" >> ~/.bashrc && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION

# Install pillow-simd for speed, followed by conda dependencies
# Clean tarballs and cache
ENV PATH /opt/conda/bin:$PATH 
RUN pip install pillow-simd && \
    conda update -n base conda -y && \
    conda env update && \
    conda clean -ya

# TINI is included in Docker versions > 1.13 (use docker run --init)
# Acts as a subprocess reaper, w/o jupyter kernels crash
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini


ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR /playground

# start our notebook
CMD ["jupyter", "notebook"]

# Suggested Usage:
# docker build -t "satchel/playground:latest" .
# docker run -p 4000:4000 -v ~/your/host/machine/dir:~/container/dir -it satchel/torch-book 
# OR
# docker compose up 