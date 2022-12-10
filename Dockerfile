FROM ubuntu:22.10
WORKDIR /
ARG ARCH=v7em_fpv4_sp_d16_hard_t_le_eabi
ARG SES_VERSION=568
ARG NCLT_MAJOR=10
ARG NCLT_MINOR=12
ARG NCLT_PATCH=1

RUN mkdir -p /_tmp /nordic && \
    apt-get -qq update && \
    apt-get install -y --no-install-recommends wget libx11-6 libfreetype6 libxrender1 libfontconfig1 libxext6 python3-pip && \
    pip3 install nrfutil && \
    wget --no-check-certificate -qO- https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-18-1/nrf-command-line-tools-10.18.1_linux-amd64.tar.gz | tar zxvfO - --wildcards *.tar | tar zxvf - --wildcards *mergehex/ -C /nordic && \
    cd /_tmp && \
    wget --no-check-certificate -qO- https://www.segger.com/downloads/embedded-studio/Setup_EmbeddedStudio_ARM_v${SES_VERSION}_linux_x64.tar.gz | tar zxvf - --wildcards */install_segger_embedded_studio && \
    printf 'yes\n' | DISPLAY=:1 $(find . -name "install_segger_embedded_studio") --copy-files-to /ses && \
    find /ses/lib/ ! -name "*${ARCH}.a" -type f -delete && \
    find /ses/segger-rtl/libs/ ! -name "*${ARCH}.a" -type f -delete && \
    find /ses/llvm/bin/ ! -name 'clang-tidy' -type f -delete && \
    find /ses/bin/ -name 'segger*' -type f -delete && \
    cd - && \
    rm -rf /_tmp

ENV PATH="/ses/bin:/nordic/mergehex:$PATH"
CMD ["/bin/sh" "-c" "[\"emBuild && nrfutil --help && mergehex --help]"]
# CMD ["emBuild && nrfutil --help && mergehex --help"]