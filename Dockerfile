FROM theiaide/theia-go:next

LABEL maintainer="askldfhjg@gmail.com"
USER root

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get update -y && apt-get install -y --no-install-recommends git-lfs zip python3-pip vim locales netcat-openbsd && rm -rf /var/lib/apt/lists/* && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8

ENV LANG zh_CN.UTF-8
ENV TZ Asia/Shanghai

RUN npm install -g gulp layadcc

RUN pip3 install Pillow==6.2.2

RUN cd /tmp && wget https://github.com/protocolbuffers/protobuf/releases/download/v3.12.1/protoc-3.12.1-linux-x86_64.zip && unzip protoc-3.12.1-linux-x86_64.zip -d ./protobuf && cd protobuf/bin && cp protoc /usr/bin/protoc && rm -rf /tmp/protobuf/* && chmod 755 /usr/bin/protoc

RUN echo 'eval "$(ssh-agent)"' >> /home/node/.bashrc && echo 'ssh-add /home/node/.ssh/*_rsa' >> /home/node/.bashrc