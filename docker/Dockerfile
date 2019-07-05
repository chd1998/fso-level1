FROM ubuntu:14.04

RUN cp /etc/apt/sources.list sources.list.bak \
	  && rm -f /etc/apt/sources.list \
		&& echo "deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list \
		&& echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
		&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list \
		&& apt-get update \
		&& apt-get install -y wget \
		&& apt-get install -y curl \
		&& apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint \
		&& rm -rf /var/lib/apt/lists/* \
#    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && cd /root/ \
		&& git clone https://github.com/coolsnowwolf/lede \	
		&& cd ./lede/ \
		&& git checkout 2915c44 \
		&& echo " " >> .gitignore \
		&& echo "/package/lean/luci-app-ssr-plus" >> .gitignore \
#		&& git checkout -b tmp \
  	&& git rm --cached package/lean/luci-app-ssr-plus -r \
    && git checkout master \
		&& git pull \
		&& ./scripts/feeds update -a \
		&& ./scripts/feeds install -a 
		
#ENV LANG en_US.utf8

WORKDIR /root

ENV FORCE_UNSAFE_CONFIGURE=1

CMD ["/bin/bash"]