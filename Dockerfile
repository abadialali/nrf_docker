FROM ubuntu:22.04 as base
WORKDIR /workdir

ARG ARCH_1=v7em_fpv4_sp_d16_hard_t_le_eabi
ARG SES_VERSION=568
ARG arch=amd64
ARG ZEPHYR_TOOLCHAIN_VERSION=0.15.2
ARG WEST_VERSION=0.14.0
ARG NRF_UTIL_VERSION=6.1.7
ARG NORDIC_COMMAND_LINE_TOOLS_VERSION="10-18-1/nrf-command-line-tools-10.18.1"

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN mkdir /workdir/.cache && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install \
        wget \
        python3-pip \
        python3-venv \
        ninja-build \
        gperf \
        git \
        unzip \
        libncurses5 libncurses5-dev \
        libyaml-dev libfdt1 \
        libusb-1.0-0-dev udev \
        device-tree-compiler \
        xz-utils \
        file \
        ruby && \
    apt-get -y clean && apt-get -y autoremove && \
    #
    # Latest PIP & Python dependencies
    #
    python3 -m pip install -U pip && \
    python3 -m pip install -U pipx && \
    python3 -m pip install -U setuptools && \
    python3 -m pip install 'cmake>=3.20.0' wheel && \
    python3 -m pip install -U "west==${WEST_VERSION}" && \
    python3 -m pip install pc_ble_driver_py && \
    # Newer PIP will not overwrite distutils, so upgrade PyYAML manually
    python3 -m pip install --ignore-installed -U PyYAML && \
    #
    # Isolated command line tools
    # No nrfutil 6+ release for arm64 (M1/M2 Macs) and Python 3, yet: https://github.com/NordicSemiconductor/pc-ble-driver-py/issues/227
    #
    case $arch in \
    "amd64") \
        PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin \
        pipx install "nrfutil==${NRF_UTIL_VERSION}" \
        ;; \
    esac && \
    #
    # ClangFormat
    #
    python3 -m pip install -U six && \
    apt-get -y install clang-format && \
    wget -qO- https://raw.githubusercontent.com/nrfconnect/sdk-nrf/main/.clang-format > /workdir/.clang-format && \
    #
    # Nordic command line tools
    # Releases: https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download
    #
    NCLT_BASE=https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x && \
    echo "Target architecture: $arch" && \
    case $arch in \
        "amd64") \
            NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-amd64.tar.gz" \
            ;; \
        "arm64") \
            NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-arm64.tar.gz" \
            ;; \
    esac && \
    echo "NCLT_URL=${NCLT_URL}" && \
    # Releases: https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Command-Line-Tools/Download
    if [ ! -z "$NCLT_URL" ]; then \
        mkdir tmp && cd tmp && \
        wget -qO - "${NCLT_URL}" | tar --no-same-owner -xz && \
        # Install included JLink
        DEBIAN_FRONTEND=noninteractive apt-get -y install ./*.deb && \
        # Install nrf-command-line-tools
        cp -r ./nrf-command-line-tools /opt && \
        ln -s /opt/nrf-command-line-tools/bin/nrfjprog /usr/local/bin/nrfjprog && \
        ln -s /opt/nrf-command-line-tools/bin/mergehex /usr/local/bin/mergehex && \
        cd .. && rm -rf tmp ; \
        
        cd /_tmp && \
        wget --no-check-certificate -qO- https://www.segger.com/downloads/embedded-studio/Setup_EmbeddedStudio_ARM_v${SES_VERSION}_linux_x64.tar.gz | tar zxvf - --wildcards */install_segger_embedded_studio && \
        printf 'yes\n' | DISPLAY=:1 $(find . -name "install_segger_embedded_studio") --copy-files-to /ses && \
        find /ses/lib/ ! -name "*${ARCH_1}.a" -type f -delete && \
        find /ses/segger-rtl/libs/ ! -name "*${ARCH_1}.a" -type f -delete && \
        find /ses/llvm/bin/ ! -name 'clang-tidy' -type f -delete && \
        find /ses/bin/ -name 'segger*' -type f -delete && \
        cd - && \
        rm -rf /_tmp ; \
    else \
        echo "Skipping nRF Command Line Tools (not available for $arch)" ; \
    fi ;
    
RUN mkdir /workdir/project

WORKDIR /workdir/project
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV XDG_CACHE_HOME=/workdir/.cache
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/workdir/zephyr-sdk
ENV ZEPHYR_BASE=/workdir/zephyr
ENV PATH="${ZEPHYR_BASE}/scripts:${PATH}"
