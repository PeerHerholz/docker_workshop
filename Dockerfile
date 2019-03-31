# This is my first Dockerfile

FROM neurodebian:nd-non-free

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/mydocker/startup.sh"

RUN export ND_ENTRYPOINT="/mydocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           git \
           git-annex-standalone \
           git-annex-remote-rclone \
           locales \
           nano \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /mydocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /mydocker && chmod a+s /mydocker

ENTRYPOINT ["/mydocker/startup.sh"]

ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"
RUN export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && sync && conda clean -tipsy && sync \
    && conda create -y -q --name ApythonEnviromentAtTheEndOfTheUniverse \
    && conda install -y -q --name ApythonEnviromentAtTheEndOfTheUniverse \
           python=3.6 \
           ipython \
           jupyter \
           nipype \
           mne \
    && sync && conda clean -tipsy && sync \
    && bash -c "source activate ApythonEnviromentAtTheEndOfTheUniverse \
    &&   pip install  --no-cache-dir \
             pandas \
             nibabel \
             nilearn \
             datalad[full]" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate ApythonEnviromentAtTheEndOfTheUniverse' $ND_ENTRYPOINT
RUN bash -c 'mydocker/startup.sh'
