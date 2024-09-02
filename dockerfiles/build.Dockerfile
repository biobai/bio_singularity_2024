FROM ubuntu:jammy

ARG MINIFORGE_NAME=Miniforge3
ARG MINIFORGE_VERSION=24.3.0-0
ARG TARGETPLATFORM
ARG MOABS_VERSION=1.3.9.6


ENV CONDA_DIR=/opt/conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV SRC_DIR=/opt/moabs-${MOABS_VERSION}
ENV PREFIX=/opt/moabs
ENV PATH=${CONDA_DIR}/bin:${PREFIX}/bin:${PATH}

# 1. Install just enough for conda to work
# 2. Keep $HOME clean (no .wget-hsts file), since HSTS isn't useful in this context
# 3. Install miniforge from GitHub releases
# 4. Apply some cleanup tips from https://jcrist.github.io/conda-docker-tips.html
#    Particularly, we remove pyc and a files. The default install has no js, we can skip that
# 5. Activate base by default when running as any *non-root* user as well
#    Good security practice requires running most workloads as non-root
#    This makes sure any non-root users created also have base activated
#    for their interactive shells.
# 6. Activate base by default when running as root as well
#    The root user is already created, so won't pick up changes to /etc/skel
RUN apt-get update > /dev/null && \
    apt-get install --yes \
        wget bzip2 ca-certificates \
        git \
        tini \
        libboost-all-dev libboost-program-options-dev libboost-thread-dev libboost-regex-dev \
        > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --no-hsts --quiet https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${MINIFORGE_NAME}-${MINIFORGE_VERSION}-Linux-$(uname -m).sh -O /tmp/miniforge.sh && \
    /bin/bash /tmp/miniforge.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniforge.sh

COPY data /opt/data


RUN mamba env create -f /opt/data/environment.yml && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate bio_singularity_2024" >> ~/.bashrc && \
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete && \
    find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete && \
    ${CONDA_DIR}/bin/conda clean -afy

RUN cd /opt/ && \
    wget --no-hsts --quiet -c https://github.com/sunnyisgalaxy/moabs/archive/refs/tags/v${MOABS_VERSION}.tar.gz && \
    tar zxf v${MOABS_VERSION}.tar.gz && \
    rm -rf v${MOABS_VERSION}.tar.gz && \
    cd moabs-${MOABS_VERSION} && \
    bash /opt/data/moabs.build.sh && \
    mv /opt/data/lut_pdiffCI.dat ${PREFIX}/bin/ && \
    mv /opt/data/lut_pdiffInRegion.dat ${PREFIX}/bin/
    
RUN rm -rf /opt/{data, moabs-${MOABS_VERSION}}
ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]
