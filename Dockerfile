# Pull base image (Rocky Linux 9)
FROM rockylinux:9

# Install dependencies & locales in a single layer
#RUN dnf -y update && \
#    dnf -y install \
#        glibc-langpack-en wget ca-certificates gcc gcc-c++ make \
#        glibc-devel openssl-devel tzdata tar shadow-utils \
#    && dnf clean all \
#    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.UTF-8

# Create redis user/group
RUN groupadd -r -g 999 redis && useradd -r -g redis -u 999 redis

# Copy and build Redis from source
COPY ./redis-stable.tar.gz /tmp/

RUN cd /tmp && \
    tar xzf redis-stable.tar.gz && \
    cd redis-stable && \
    export BUILD_TLS=yes && \
    make && make install && \
    mkdir -p /etc/redis /var/log/redis && \
    cp -f *.conf /etc/redis && \
    rm -rf /tmp/redis-stable*

# Copy custom config
COPY ./redis.conf /etc/redis

# Create mountable directories
RUN mkdir /data && chown redis:redis /data

VOLUME ["/data", "/etc/redis", "/var/log/redis"]

# Set working directory
WORKDIR /data

# Expose Redis default port
EXPOSE 6379

# Default command
CMD ["redis-server", "/etc/redis/redis.conf"]
