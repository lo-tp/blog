FROM node:latest

RUN apt-get install git-core
RUN  npm install --registry=https://registry.npm.taobao.org -g hexo-cli
RUN  npm install --registry=https://registry.npm.taobao.org hexo-server --save
RUN mkdir /blog
WORKDIR /blog

# Set Your Own Username to Be Used in Lieu of Root
RUN useradd lotp
USER lotp
