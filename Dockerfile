FROM ubuntu
MAINTAINER ukatama dev.ukatama@gmail.com

RUN apt-get update -y -q

# Utilities
RUN apt-get install -y -q \
	wget

# Install Pre-Requirements
RUN apt-get install -y -q \
	build-essential \
	libpcap-dev \
	libpcre3-dev \
	libdumbnet-dev \
	bison \
	flex \
	zlib1g-dev

# Build and Install
RUN wget -q https://snort.org/downloads/snort/daq-2.0.6.tar.gz
RUN tar xvf daq-2.0.6.tar.gz
RUN cd daq-2.0.6 && ./configure && make install

RUN wget -q https://snort.org/downloads/snort/snort-2.9.8.0.tar.gz
RUN tar xvf snort-2.9.8.0.tar.gz
RUN cd snort-2.9.8.0 && ./configure && make install
RUN ldconfig

# Create User
RUN groupadd snort
RUN useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

# Make Directories
RUN mkdir /var/log/snort
RUN mkdir /usr/local/lib/snort_dynamicrules
RUN chown -R snort:snort /var/log/snort
RUN chown -R snort:snort /usr/local/lib/snort_dynamicrules

# Add Configurations
ADD ./etc /etc/snort
RUN chown -R snort:snort /etc/snort

# Check Configurations
RUN snort -T -c /etc/snort/snort.conf -u snort -g snort

# Entry Point
ENTRYPOINT snort -A console -q -c /etc/snort/snort.conf -i $INTERFACE -u snort -g snort
