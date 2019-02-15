FROM docker:1.13

RUN apk add --update automake libtool libarchive libarchive-dev python m4 autoconf alpine-sdk linux-headers && \
    wget -qO- https://github.com/singularityware/singularity/releases/download/2.6.0/singularity-2.6.0.tar.gz | tar zxv && \
    cd singularity-2.6.0 && ./autogen.sh && ./configure --prefix=/usr/local && make && make install && \
    cd ../ && rm -rf singularity-2.6 && \
    apk del automake libtool m4 autoconf alpine-sdk linux-headers

RUN mkdir -p /usr/local/var/singularity/mnt

RUN apk add e2fsprogs bash tar rsync squashfs-tools
ADD docker2singularity.sh /docker2singularity.sh
RUN chmod a+x docker2singularity.sh

# switch out tar due to issue on Mac.  
# issue #44
RUN apk add --update libarchive-tools && \
    apk del tar && \
    ln -sf $(which bsdtar) /usr/bin/_tar
ADD tar /usr/local/bin/tar
RUN rm /bin/tar

ENTRYPOINT ["docker-entrypoint.sh", "/docker2singularity.sh"]
