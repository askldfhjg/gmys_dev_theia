FROM node:10
WORKDIR /home/theia
ADD next.package.json ./package.json
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

# See : https://github.com/theia-ide/theia-apps/issues/34
RUN adduser --disabled-password --gecos '' theia && \
    chmod g+rw /home && \
    mkdir -p /home/project && \
    mkdir -p /home/go && \
    mkdir -p /home/go-tools && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/project && \
    chown -R theia:theia /home/go && \
    chown -R theia:theia /home/go-tools;
USER theia

ENV GO_VERSION=1.14.4 \
    GOOS=linux \
    GOARCH=amd64 \
    GOROOT=/home/go \
    GOPATH=/home/go-tools
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# install Go
RUN curl -fsSL https://storage.googleapis.com/golang/go$GO_VERSION.$GOOS-$GOARCH.tar.gz | tar -C /home -xzv

# install VS Code Go tools: https://github.com/Microsoft/vscode-go/blob/058eccf17f1b0eebd607581591828531d768b98e/src/goInstallTools.ts#L19-L45
RUN go get -u -v github.com/mdempsky/gocode && \
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get -u -v github.com/ramya-rao-a/go-outline && \
    go get -u -v github.com/acroca/go-symbols && \
    go get -u -v golang.org/x/tools/cmd/guru && \
    go get -u -v golang.org/x/tools/cmd/gorename && \
    go get -u -v github.com/fatih/gomodifytags && \
    go get -u -v github.com/haya14busa/goplay/cmd/goplay && \
    go get -u -v github.com/josharian/impl && \
    go get -u -v github.com/tylerb/gotype-live && \
    go get -u -v github.com/rogpeppe/godef && \
    go get -u -v github.com/zmb3/gogetdoc && \
    go get -u -v golang.org/x/tools/cmd/goimports && \
    go get -u -v github.com/sqs/goreturns && \
    go get -u -v winterdrache.de/goformat/goformat && \
    go get -u -v golang.org/x/lint/golint && \
    go get -u -v github.com/cweill/gotests/... && \
    go get -u -v github.com/alecthomas/gometalinter && \
    go get -u -v honnef.co/go/tools/... && \
    GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint && \
    go get -u -v github.com/mgechev/revive && \
    go get -u -v github.com/sourcegraph/go-langserver && \
    go get -u -v github.com/go-delve/delve/cmd/dlv && \
    go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get -u -v github.com/godoctor/godoctor

RUN go get -u -v -d github.com/stamblerre/gocode && \
    go build -o $GOPATH/bin/gocode-gomod github.com/stamblerre/gocode

# configure Theia
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins  \
    # configure user Go path
    GOPATH=/home/project
ENV PATH=$PATH:$GOPATH/bin

EXPOSE 3000
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]

LABEL maintainer="askldfhjg@gmail.com"
USER root

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get update -y && apt-get install -y --no-install-recommends git-lfs zip python3-pip vim locales netcat-openbsd && rm -rf /var/lib/apt/lists/* && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8

ENV LANG zh_CN.UTF-8
ENV TZ Asia/Shanghai

RUN npm install -g gulp layadcc

RUN pip3 install Pillow==6.2.2

RUN cd /tmp && wget https://github.com/protocolbuffers/protobuf/releases/download/v3.12.1/protoc-3.12.1-linux-x86_64.zip && unzip protoc-3.12.1-linux-x86_64.zip -d ./protobuf && cd protobuf/bin && cp protoc /usr/bin/protoc && rm -rf /tmp/protobuf/* && chmod 755 /usr/bin/protoc

RUN echo 'eval "$(ssh-agent)"' >> /home/node/.bashrc && echo 'ssh-add /home/node/.ssh/*_rsa' >> /home/node/.bashrc