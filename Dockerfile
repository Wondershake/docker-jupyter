FROM python:3.6.2-alpine3.6

ENV TOKENIZER_HASH 42789a13a8a5e66be92b61e56b6a2eb365559f50
ENV CRF_DRIVE_HASH 0B4y35FiV1wh7QVR6VXJ5dWExSTQ
ENV CABOCHA_DRIVE_HASH 0B4y35FiV1wh7SDd1Q1dUQkZQaUU
ENV CABOCHA_WRAPPER_HASH 62a0d58e5d051f35b77eb6bc5858c87698c8038c

# Install apk Packages
RUN apk update \
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
    freetype-dev \
    g++ \
    gcc \
    gfortran \
    git \
    lapack-dev \
    libxml2-dev \
    libxslt-dev \
    make \
    openssl \
    perl \
    wget

# Install Japanese Morphological Analyzers
RUN git clone \
    --depth=1 \
    https://github.com/Kensuke-Mitsuzawa/JapaneseTokenizers.git \
    /usr/local/src/JapaneseTokenizers \
  && cd /usr/local/src/JapaneseTokenizers \
  && git checkout ${TOKENIZER_HASH} \
  && make install \
  && make install_neologd \
  && python setup.py install \
  && cd \
  && rm -rf /usr/local/src/JapaneseTokenizers

# Install Cabocha
RUN cd /usr/local/src \
  # Download CRF++
  && wget "https://drive.google.com/uc?export=download&id=$CRF_DRIVE_HASH" -O crf.tar.gz \
  && mkdir crf && tar -xvzf crf.tar.gz -C crf --strip-components 1 \

  # Download Cabocha++
  && curl -sc /usr/local/src/cookie "https://drive.google.com/uc?export=download&id=$CABOCHA_DRIVE_HASH" > /dev/null \
  && CODE="$(awk '/_warning_/ {print $NF}' /usr/local/src/cookie)" \
  && curl -Lb /usr/local/src/cookie "https://drive.google.com/uc?export=download&confirm=$CODE&id=$CABOCHA_DRIVE_HASH" -o cabocha.tar.bz2 \
  && mkdir cabocha && tar -xjvf cabocha.tar.bz2 -C cabocha --strip-components 1 \

  # Download Cabocha wrapper
  && git clone https://github.com/kenkov/cabocha cabocha_wrapper \

  # Build CRF++
  && cd /usr/local/src/crf && ./configure && make && make install \

  # Build Cabocha
  && cd /usr/local/src/cabocha && ./configure --with-charset=UTF8 && make && make install \
  && pip install ./python/ \

  # Install Cabocha wrapper
  && cd /usr/local/src/cabocha_wrapper && git checkout ${CABOCHA_WRAPPER_HASH} \
  && pip install ./ \

  # Clean directories
  && rm -rf /usr/local/src/crf \
  && rm -rf /usr/local/src/cabocha \
  && rm -rf /usr/local/src/cabocha_wrapper \
  && rm /usr/local/src/cookie

# Install Google Cloud SDK
RUN apk --update --no-cache add python2 \
  && mkdir /opt \
  && curl -o /opt/google-cloud-sdk.tar.gz \
    https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-158.0.0-linux-x86_64.tar.gz \
  && cd /opt \
  && tar zxf google-cloud-sdk.tar.gz \
  && rm google-cloud-sdk.tar.gz \
  && CLOUDSDK_PYTHON=$(which python2) \
    google-cloud-sdk/install.sh \
    --usage-reporting=false \
    --rc-path=/etc/profile.d/gcloud.sh \
    --quiet

# Install Python Packages
RUN pip --no-cache-dir install PyYAML
RUN pip --no-cache-dir install gensim
RUN pip --no-cache-dir install inflection
RUN pip --no-cache-dir install jupyter
RUN pip --no-cache-dir install matplotlib
RUN pip --no-cache-dir install neologdn
RUN pip --no-cache-dir install numpy
RUN pip --no-cache-dir install pandas
RUN pip --no-cache-dir install pandas_gbq
RUN pip --no-cache-dir install scikit-learn
RUN pip --no-cache-dir install scipy
RUN pip --no-cache-dir install tqdm

# Make Directories
RUN mkdir /notebook

# Configure Jupyter Notebook
ADD jupyter_notebook_config.py /root/.jupyter/

# Enable jupyter_contrib_nbextensions
# https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator
RUN pip --no-cache-dir install jupyter_contrib_nbextensions \
  && jupyter contrib nbextension install --user \
  && pip --no-cache-dir install jupyter_nbextensions_configurator \
  && jupyter nbextensions_configurator enable --user

# Install font for Japanese (using matplotlib)
RUN mkdir -p /usr/share/fonts
COPY IPAGothic /usr/share/fonts/IPAGothic
RUN fc-cache -fv

# Ports
EXPOSE 8888

# Volumes
VOLUME /notebook
VOLUME /root/.config/gcloud

WORKDIR /notebook
CMD jupyter notebook
