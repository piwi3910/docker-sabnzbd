FROM piwi3910/base:latest

LABEL maintainer="Pascal Watteel"


# par2 packages isn't available, building in virtual system
RUN apk update && \
    apk add --no-cache ca-certificates wget && \
	apk add --no-cache --virtual .build-dependencies make g++ automake autoconf && \
	update-ca-certificates && \
    wget https://github.com/Parchive/par2cmdline/archive/refs/tags/v0.8.1.tar.gz && \
	tar -xzvf v0.8.1.tar.gz && \
	cd par2cmdline-0.8.1 && \
	aclocal && \
	automake --add-missing && \
	autoupdate && \
    autoconf && \
	./configure && \
	make && \
	make install && \
    apk del .build-dependencies && \
	cd / && \
	rm -rf par2cmdline-0.8.1 v0.8.1.tar.gz


#
# Install python and other required packages (https://github.com/sabnzbd/sabnzbd/blob/master/INSTALL.txt#L58)
#
RUN apk add \
   py3-pip \
   py3-openssl \
   p7zip \
   python3 \
   unrar \
   --no-cache

#
# Add SABnzbd init script.
#
COPY sabnzbd.sh /sabnzbd.sh

#
# Fix locales to handle UTF-8 characters.
#
ENV LANG C.UTF-8

#
# Specify versions of software to install.
#
ARG SABNZBD_VERSION=DEFAULT

#
# Add (download) sabnzbd
#
ADD https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz /tmp/sabnzbd.tar.gz

#
# Install SABnzbd and requied dependencies (https://github.com/sabnzbd/sabnzbd/blob/master/INSTALL.txt#L67)
#
RUN adduser -u 666 -D -h /sabnzbd -s /bin/bash sabnzbd sabnzbd && \
    chmod 755 /sabnzbd.sh &&\
    tar xzf /tmp/sabnzbd.tar.gz -C /tmp &&\
    mv /tmp/SABnzbd-*/* /sabnzbd/ &&\
    apk add --no-cache --virtual .build-dependencies make g++ gcc automake autoconf python3-dev &&\
    python3 -m pip install -r /sabnzbd/requirements.txt &&\
    apk del .build-dependencies &&\
    chown -R sabnzbd: sabnzbd &&\
    rm -rf /tmp/SAB* /tmp/sab* &&\
    mkdir -p /downloads/complete /downloads/incomplete


#
# Define container settings.
#
VOLUME ["/datadir", "/downloads"]

EXPOSE 8080

#
# Start SABnzbd.
#

WORKDIR /sabnzbd

CMD ["/sabnzbd.sh"]
