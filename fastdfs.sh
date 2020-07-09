#!/bin/bash

#安装依赖包
yum install -y make cmake gcc gcc-c++

#创建安装目录
FASTDFS_HOME=/usr/local/fastdfs
mkdir -p $FASTDFS_HOME

#fastdfs
FASTDFS_TRACKER=/fastdfs/tracker
#创建tracker目录
mkdir -p $FASTDFS_TRACKER

#storage
FASTDFS_STORAGE=/fastdfs/storage
mkdir $FASTDFS_STORAGE

TRACKER_IP="192.168.100.10"

#下载文件
wget http://yellowcong.qiniudn.com/FastDFS_package.zip -O  $FASTDFS_HOME/FastDFS.zip

#解压文件
#解压下载的文件
unzip $FASTDFS_HOME/FastDFS.zip -d $FASTDFS_HOME/ >/dev/null

#==========================================
#安装 fastcommon
FASTDFS_DIR=$FASTDFS_HOME/FastDFS
#解压fastcommon
unzip $FASTDFS_DIR/libfastcommon-master.zip -d $FASTDFS_DIR/libfastcommon >/dev/null

cd $FASTDFS_DIR/libfastcommon/libfastcommon-master
#编译
./make.sh

#安装
./make.sh install

#==============建立软连接============================
#libfastcommon
ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so
ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so

#libfdfsclient（这个我没有libfdfsclient.so ，也没有配置，也好用）
ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so

#==============安装tracker服务========================
#解压trackerFastDFS_v5.05.tar.gz
tar -zxvf $FASTDFS_DIR/FastDFS_v5.05.tar.gz -C $FASTDFS_DIR >/dev/null
#tar -zxvf FastDFS_v5.05.tar.gz -C /usr/local/fastdfs/FastDFS

echo "安装tracker 服务"
echo $FASTDFS_DIR
#进入目录
cd $FASTDFS_DIR/FastDFS/


#编译
./make.sh

#安装
./make.sh install

#修改脚本的启动目录
#/etc/init.d/fdfs_storaged
#修改storaged的 bin
sed -i 's#/usr/local/bin#/usr/bin#g' /etc/init.d/fdfs_storaged

#/etc/init.d/fdfs_trackerd
sed -i 's#/usr/local/bin#/usr/bin#g' /etc/init.d/fdfs_trackerd

#=================配置tracker（跟踪器）======================
echo "配置tracker"

#/etc/fdfs
cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf

#修改base_path
sed -i 's#/home/yuqing/fastdfs#'$FASTDFS_TRACKER'#g' /etc/fdfs/tracker.conf

#启动tracker服务
/etc/init.d/fdfs_trackerd start

#====================配置storage================================
echo "配置storage"
#配置storage
cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf


#FASTDFS_STORAGE
sed -i 's#/home/yuqing/fastdfs#'$FASTDFS_STORAGE'#g' /etc/fdfs/storage.conf

#配置tracker(跟踪器)
#tracker_server=192.168.66.110:22122
sed -i 's#192.168.209.121:22122#'$TRACKER_IP':22122#g'  /etc/fdfs/storage.conf

#启动storaged服务
/etc/init.d/fdfs_storaged start

#=================配置客户端==================================
echo "配置客户端"
#客户端
cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf

#配置tracker(跟踪器)存储目录
sed -i 's#/home/yuqing/fastdfs#'$FASTDFS_TRACKER'#g' /etc/fdfs/client.conf

sed -i 's#192.168.0.197:22122#'$TRACKER_IP':22122#g'  /etc/fdfs/client.conf

#执行 上传测试
echo test>$FASTDFS_DIR/test.txt
echo "执行下面测试文件"
echo "/usr/bin/fdfs_upload_file /etc/fdfs/client.conf "$FASTDFS_DIR"/test.txt"

