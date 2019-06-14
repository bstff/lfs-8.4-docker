FROM ubuntu:16.04

RUN echo "deb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial universe" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties" >> /etc/apt/sources.list && \
    echo "deb http://archive.canonical.com/ubuntu xenial partner" >> /etc/apt/sources.list && \
    echo "deb-src http://archive.canonical.com/ubuntu xenial partner" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse" >> /etc/apt/sources.list 

# image info
LABEL description="Automated LFS build"
LABEL version="8.4"
LABEL maintainer="ilya.builuk@gmail.com"

# LFS mount point
ENV LFS=/mnt/lfs

# Other LFS parameters
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV MAKEFLAGS="-j 4"

# Defines how toolchain is fetched
# 0 use LFS wget file
# 1 use binaries from toolchain folder
# 2 use github release artifacts
ENV FETCH_TOOLCHAIN_MODE=1

# set 1 to run tests; running tests takes much more time
ENV LFS_TEST=0

# set 1 to install documentation; slightly increases final size
ENV LFS_DOCS=1

# degree of parallelism for compilation
ENV JOB_COUNT=4

# loop device
ENV LOOP=/dev/loop6

# inital ram disk size in KB
# must be in sync with CONFIG_BLK_DEV_RAM_SIZE
ENV IMAGE_SIZE=3200000

# location of initrd tree
ENV INITRD_TREE=/mnt/lfs

# output image
ENV IMAGE=isolinux/ramdisk.img

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# install required packages
RUN apt-get update && apt-get install -y --fix-missing \
    build-essential                      \
    bison                                \
    file                                 \
    gawk                                 \
    texinfo                              \
    wget                                 \
    sudo                                 \
    genisoimage                          \
    bash                                 \
    python3                                 \
 && apt-get -q -y autoremove             \
 && rm -rf /var/lib/apt/lists/*

# create sources directory as writable and sticky
RUN mkdir -pv     $LFS/sources \
 && chmod -v a+wt $LFS/sources
WORKDIR $LFS/sources

# create tools directory and symlink
RUN mkdir -pv $LFS/tools   \
 && ln    -sv $LFS/tools /

# copy local binaries if present
COPY ["toolchain/", "$LFS/sources/"]

# copy scripts
COPY [ "scripts/run-all.sh",       \
       "scripts/library-check.sh", \
       "scripts/version-check.sh", \
       "scripts/prepare/",         \
       "scripts/build/",           \
       "scripts/image/",           \
  "$LFS/tools/" ]
# copy configuration
COPY [ "config/kernel.config", "$LFS/tools/" ]

# check environment
RUN chmod +x $LFS/tools/*.sh    \
 && sync                        \
 && $LFS/tools/version-check.sh \
 && $LFS/tools/library-check.sh

# create lfs user with 'lfs' password
RUN groupadd lfs                                    \
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd
RUN adduser lfs sudo

# give lfs user ownership of directories
RUN chown -v lfs $LFS/tools  \
 && chown -v lfs $LFS/sources

# avoid sudo password
RUN echo "lfs ALL = NOPASSWD : ALL" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LFS LC_ALL LFS_TGT PATH MAKEFLAGS FETCH_TOOLCHAIN_MODE LFS_TEST LFS_DOCS JOB_COUNT LOOP IMAGE_SIZE INITRD_TREE IMAGE"' >> /etc/sudoers

# login as lfs user
USER lfs
COPY [ "config/.bash_profile", "config/.bashrc", "/home/lfs/" ]
RUN source ~/.bash_profile

# let's the party begin
ENTRYPOINT [ "/tools/run-all.sh" ]