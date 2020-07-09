#!/bin/sh
# Purposes: get latest release of trojan
# Usage: upgrade-trojan.sh  owner project ostype arch
# Example: ./upgrade-trojan.sh trojan-gfw trojan linux amd64
# NOTE: Press Ctrl+C to break
#
# Change History:
#                20200704 20:50  Release 0.1 : first working prototype
#                20200708 18:18  Release 0.2 : revised
#
cyear=`date  +%Y`
today=`date  +%Y-%m-%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
ctime0=`date  +%H:%M:%S`

if [ $# -ne 4 ];then
  echo "Usage: upgrade-trojan.sh  owner project ostype arch"
  echo "Example: ./upgrade-trojan.sh trojan-gfw trojan linux amd64"
#  echo "press ctrl-c to break!"
  exit 0
fi
echo "$today0 $ctime0 : Getting latest version number..."
vname=`wget -qO- -t1 -T2 "https://api.github.com/repos/$1/$2/releases/latest"|grep "tag_name" |sed -E 's/.*"([^"]+)".*/\1/'`
vdigi=`echo ${vname}| cut -c 2-`
#echo $vname
#echo $vdigi

pver=0.2
durl="https://github.com/$1/$2/releases/download/$vname/trojan-$vdigi-$3-$4.tar.xz"
echo "$today0 $ctime0 : Getting $durl..."
wget -q $durl &
wait
if [ $? -ne 0 ];then
  ctime1=`date  +%H:%M:%S`
  echo "$today0 $ctime1: Failed in gettting $vname trojan file from github.com..."
  cd /home/chd
  exit 1
fi
today1=`date  +%Y-%m-%d`
ctime2=`date  +%H:%M:%S`
echo "$today1 $ctime2 : Extracting  trojan-$vdigi-$3-$4.tar.xz"
tar -xf ./trojan-$vdigi-$3-$4.tar.xz
cd ./trojan
today1=`date  +%Y-%m-%d`
ctime2=`date  +%H:%M:%S`
echo "$today1 $ctime2 : Stop $1 service..."
systemctl stop $1
today1=`date  +%Y-%m-%d`
ctime2=`date  +%H:%M:%S`
echo "$today1 $ctime2 : Upgrading trojan to $vname..."
cp -f trojan /usr/bin/.
today1=`date  +%Y-%m-%d`
ctime2=`date  +%H:%M:%S`
echo "$today1 $ctime2 : Restart $1 service..."
systemctl start $1
if [ $? -ne 0 ];then
  today2=`date  +%Y-%m-%d`
  ctime3=`date  +%H:%M:%S`
  echo "$today2 $ctime3: Failed in upgrading $vname $3 $4 trojan file..."
  cd /home/chd
  exit 1
fi
cd ..
rm -f ./trojan-$vdigi-$3-$4.tar.xz
rm -rf ./trojan
today1=`date  +%Y-%m-%d`
ctime2=`date  +%H:%M:%S`
echo "$today1 $ctime2 : Succeeded in upgrading trojan to $vname..."

