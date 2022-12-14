FROM ubuntu:18.04

# Install SEGGER Embedded Studio 5.68
RUN apt-get update && apt-get install -y wget
RUN wget https://www.segger.com/downloads/embedded-studio/Setup_EmbeddedStudio_Linux_x64.tar
RUN tar -xvf Setup_EmbeddedStudio_Linux_x64.tar
RUN rm Setup_EmbeddedStudio_Linux_x64.tar
RUN ./Setup_EmbeddedStudio_Linux_x64

# Add embuild to PATH
ENV PATH "$PATH:/opt/SEGGER/EmbeddedStudio/5.68/emBuild/bin"
