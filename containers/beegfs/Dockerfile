# Use an official Python runtime as a parent image
FROM debian:latest

# Set the working directory to /app and coopy files
WORKDIR /beegfs
COPY requirements.txt /beegfs/

# Install packages required and set aliases
RUN apt-get update && apt-get --assume-yes install $(cat requirements.txt) \
	&& echo 'alias ll="ls -l --color"' >> ~/.bashrc \
	&& echo 'alias la="ls -la --color"' >> ~/.bashrc \
	&& pip3 install python-hostlist

# Install BeeGFS
#   * beegfs-mgmtd: Management Server (one node)
#   * beegfs-meta: Metadata Server
#   * beegfs-storage: Storage Server
#   * beegfs-admon: Real-time I/O monitoring
#
# link: https://www.beegfs.io/wiki/DownloadInstallationPackages
RUN wget https://www.beegfs.io/release/latest-stable/dists/beegfs-deb9.list -O /etc/apt/sources.list.d/beegfs-deb9.list \
	&& wget -q https://www.beegfs.io/release/latest-stable/gpg/DEB-GPG-KEY-beegfs -O- | apt-key add - \
	&& apt-get update \
	&& apt-get --assume-yes install beegfs-mgmtd beegfs-meta beegfs-storage beegfs-utils beegfs-admon

ENTRYPOINT /bin/bash
