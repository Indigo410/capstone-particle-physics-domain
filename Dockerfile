FROM ucsdets/scipy-ml-notebook:2020.2.9

LABEL maintainer="Javier Duarte <jduarte@ucsd.edu>"

USER root
#WORKDIR /root

# Install cmake and XRootD
RUN apt-get update && \
    apt-get upgrade -qq -y && \
    apt-get install -qq -y \
    python3-pip \
    cmake && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
ADD install_xrootd.sh install_xrootd.sh
RUN bash install_xrootd.sh && \
    rm install_xrootd.sh
ENV PATH /opt/xrootd/bin:${PATH}
ENV LD_LIBRARY_PATH /opt/xrootd/lib

RUN conda install -n ml-latest -c conda-forge uproot xrootd scikit-learn matplotlib tqdm 

# Create the environment:
SHELL ["conda", "run", "-n", "ml-latest", "/bin/bash", "-c"]

ENV CUDA=cu101

ENV TORCH=1.5.0

RUN pip install torch-scatter==latest+${CUDA} -f https://pytorch-geometric.com/whl/torch-${TORCH}.html \
    && pip install torch-sparse==latest+${CUDA}  -f https://pytorch-geometric.com/whl/torch-${TORCH}.html \
    && pip install torch-cluster==latest+${CUDA}  -f https://pytorch-geometric.com/whl/torch-${TORCH}.html \
    && pip install torch-spline-conv==latest+${CUDA}  -f https://pytorch-geometric.com/whl/torch-${TORCH}.html \
    && pip install torch-geometric \
    && pip install -U jupyter-book


ADD fix-permissions fix-permissions

RUN chmod +x fix-permissions

RUN fix-permissions /home/$NB_USER

#RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
#    usermod -aG sudo jovyan && \
#    usermod -aG root jovyan

#EXPOSE 8888

USER $NB_USER
WORKDIR /home/$NB_USER

ENV USER=${NB_USER}
