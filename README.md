# gmys_dev_theia
gmys在线开发环境-theia

## 用法
docker run --security-opt seccomp=unconfined -e GO111MODULE=auto -it -p 3000:3000 -u $(id -u) --ulimit memlock=-1 -v "/home/user/Documents/code:/home/project" -v "/home/user/.ssh:/home/node/.ssh" -v "/home/user/go:/home/node/go" -v "/home/user/.gitconfig:/home/node/.gitconfig" askldfhjg/gmys_dev