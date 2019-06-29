FROM python:3.7.3-alpine3.9

# Install apk Packages
RUN set -ex \
  && apk update \
  # Install Dependencies
  && apk --no-cache add \
    libstdc++ \
  # Install Utilities
  && apk --no-cache add \
    bash \
  # Install Build Dependencies
  && apk --no-cache add --virtual .build-deps \
    curl \
    file \
    fontconfig \
    freetype-dev \
    g++ \
    gcc \
    gfortran \
    git \
    lapack-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    openssl \
    perl \
    swig \
    wget \
    zeromq-dev

# Install font for Japanese (using matplotlib)
RUN mkdir -p /usr/share/fonts
COPY IPAGothic /usr/share/fonts/IPAGothic
RUN fc-cache -fv

# Install Google Cloud SDK
RUN set -ex \
  && apk --update --no-cache add python2 \
  && curl -o /opt/google-cloud-sdk.tar.gz \
    https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-196.0.0-linux-x86_64.tar.gz \
  && cd /opt \
  && tar zxf google-cloud-sdk.tar.gz \
  && rm google-cloud-sdk.tar.gz \
  && CLOUDSDK_PYTHON=$(which python2) \
    google-cloud-sdk/install.sh \
    --usage-reporting=false \
    --rc-path=/etc/profile.d/gcloud.sh \
    --quiet

# Install Japanese Morphological Analyzers
RUN set -ex \
  && git clone \
    --branch=1.6 --depth=1 \
    https://github.com/Kensuke-Mitsuzawa/JapaneseTokenizers.git \
    /usr/local/src/JapaneseTokenizers \
  && cd /usr/local/src/JapaneseTokenizers \
  && make install \
  && make install_neologd \
  && python setup.py install \
  && cd \
  && rm -rf /usr/local/src/JapaneseTokenizers

RUN mkdir /app

WORKDIR /app

# Install Python packages
RUN pip3 --no-cache-dir install pipenv
COPY Pipfile Pipfile.lock ./
RUN pipenv sync

# Enable jupyter_contrib_nbextensions
# https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator
RUN set -ex \
  && pipenv run jupyter contrib nbextension install --user \
  && pipenv run jupyter nbextensions_configurator enable --user

# Make Directories
RUN mkdir /notebook

# Configure Jupyter Notebook
COPY jupyter_notebook_config.py /root/.jupyter/

# Ports
EXPOSE 8888

# Volumes
VOLUME /notebook
VOLUME /root/.config/gcloud

CMD pipenv run jupyter notebook
