# Run MetaTrader in a container.
#
# Copyright (c) 2021 tick <tickelton@gmail.com>
#
# SPDX-License-Identifier:     ISC
#
# docker run \
#	--net host \
#	-v /tmp/.X11-unix:/tmp/.X11-unix \
#	-e DISPLAY \
#	-v $METATRADER_HOST_PATH:/MetaTrader \
#	--name mt \
#	tickelton/mt

# Base docker image.
FROM ubuntu:groovy

# RUN apt-get update && \
	# apt-get install -y gnupg apt-utils x11vnc xvfb && \
	# echo "deb http://dl.winehq.org/wine-builds/ubuntu/ groovy main" >> /etc/apt/sources.list && \
	# apt-key add Release.key && \
	# dpkg --add-architecture i386 && \
	# apt-get update && \
	# apt-get install -y --install-recommends winehq-stable && \
	# rm -rf /var/lib/apt/lists/* /Release.key
# Update packages 
RUN apt-get update && \
	apt-get install -y apt-utils gnupg wget x11vnc xvfb

# Install Wine
ADD https://dl.winehq.org/wine-builds/winehq.key /Release.key
RUN echo "deb http://dl.winehq.org/wine-builds/ubuntu/ groovy main" >> /etc/apt/sources.list && \
	apt-key add Release.key && \
	dpkg --add-architecture i386 && \
	apt-get update && \
	# apt-get install -y --install-recommends winehq-devel && \
	apt-get install -y --install-recommends winehq-stable && \
	rm -rf /var/lib/apt/lists/* /Release.key


RUN set -ex; \
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks; \
    chmod +x winetricks; \
    mv winetricks /usr/local/bin
ADD waitonprocess.sh /usr/local/bin

# Add wine user.
# NOTE: You might need to change the UID/GID so the
# wine user has write access to your MetaTrader
# directory at $METATRADER_HOST_PATH.
RUN groupadd -g 1000 wine \
	&& useradd -g wine -u 1000 wine \
	&& mkdir -p /home/wine/.wine && chown -R wine:wine /home/wine
RUN getent passwd

# Run MetaTrader as non privileged user.
USER wine
ENV DISPLAY=:0 \
    SCREEN_NUM=0 \
    SCREEN_WHD=1366x768x24

# Install .NET
RUN set -ex; \
    wine wineboot --init; \
    waitonprocess.sh wineserver; \
    winetricks --unattended dotnet40; \
    waitonprocess.sh wineserver

# Add run script
ADD run.sh /tmp
EXPOSE 5900

# Run Terminal
ENTRYPOINT ["/bin/bash"]
CMD ["/tmp/run.sh"]