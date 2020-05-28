FROM theiaide/theia-go:next

LABEL maintainer="askldfhjg@gmail.com"
USER root

RUN npm install -g gulp layadcc
RUN apt-get update -y && apt-get -y install zip python3-pip vim
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get -y install git-lfs
RUN pip3 install Pillow==6.2.2
RUN cd /tmp && wget https://github.com/protocolbuffers/protobuf/releases/download/v3.12.1/protoc-3.12.1-linux-x86_64.zip && unzip protoc-3.12.1-linux-x86_64.zip -d ./protobuf && cd protobuf/bin && cp protoc /usr/bin/protoc
RUN chmod 755 /usr/bin/protoc
RUN echo 'eval "$(ssh-agent)"' >> /home/node/.bashrc
RUN echo 'ssh-add ~/home/node/.ssh/*_rsa' >> /home/node/.bashrc