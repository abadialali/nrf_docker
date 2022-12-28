FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncursed5 \
    wget

# Download Segger Embedded Studio 5.68
RUN wget https://www.segger.com/downloads/embedded-studio/Setup_EmbeddedStudio_ARM_v5.68.exe

# Install Segger Embedded Studio 5.68
RUN chmod +x Setup_EmbeddedStudio_ARM_v5.68.exe && \
    ./Setup_EmbeddedStudio_ARM_v5.68.exe --quiet --norestart --prefix /opt/segger && \
    rm Setup_EmbeddedStudio_ARM_v5.68.exe

# Add Segger Embedded Studio to PATH
ENV PATH="/opt/segger/SEGGER Embedded Studio for ARM 5.68/bin:${PATH}"

# Set the working directory
WORKDIR /opt/segger/SEGGER Embedded Studio for ARM 5.68
