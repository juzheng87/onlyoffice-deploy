#!/usr/bin/env bash
if [ ! -n "$1" ] ;then
    echo "必须指定一个安装目录"
    exit
fi

if [ ! -n "$2" ] ;then
    echo "必须指定访问毕升文档的域名"
    exit
fi

if [ ! -x "$1" ] ;then
     mkdir "$1"
fi

echo "copy resource data"

rm -rf $1/*
docker rm nginx minio dgraphServer dgraphZero redis dgraphRatel rabbit search mongod  drive_full editor_app convert editor -f  1 > /dev/null 2>&1
docker network create bisheng 1 > /dev/null 2>&1

export basedir=$1
export tag=free
sh pullImage.sh $tag

echo "$1 $2 free" > .config

mkdir $1/{service,workspace,resource,ningx}

cp -r service/* $1/service
cp -r workspace/* $1/workspace
cp -r resource/* $1/resource
cp -r ningx/* $1/ningx


cd $1/service

sysctl -w vm.max_map_count=262144
mkdir -p dgraph
mkdir -p mongod/{db,log}
touch  mongod/log/mongod.log
mkdir -p rabbitmq/{data}
mkdir -p minio/{config,data}
mkdir -p elasticsearch/{data,logs}
mkdir -p nginx/{temp,keys}
touch  nginx/temp/error.log
touch  nginx/temp/access.log
mkdir  nginx/config/conf.d
sed -e 's/HOST/'$2'/g' ../workspace/config/bisheng.conf >  nginx/config/conf.d/bisheng.conf

chmod 777 elasticsearch/ -R


docker-compose up -d

cd -



#cp config.sample.yml config.yml

sed -e 's/HOST/'$2'/g' workspace/config/config.sample.yml > $1/workspace/config/config.yml

sleep 60


sh init.sh 7 free



cd $1/workspace
mkdir temp
mkdir logs

docker-compose up -d

sleep 30

cd -


sh init.sh 8 free



cd $1/ningx
docker-compose up -d

