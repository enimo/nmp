#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
echo "========================================================================="
echo "LNMP V1.1 for Ubuntu Linux Server, Written by Licess "
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo "========================================================================="
cur_dir=$(pwd)

#set mysql root password

	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
	echo "==========================="
	echo "mysqlrootpwd=$mysqlrootpwd"
	echo "==========================="

#do you want to install the InnoDB Storage Engine?

echo "==========================="

	installinnodb="n"
	echo "Do you want to install the InnoDB Storage Engine?"
	read -p "(Default no,if you want please input: y ,if not please press the enter button):" installinnodb

	case "$installinnodb" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install the InnoDB Storage Engine"
	installinnodb="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will NOT install the InnoDB Storage Engine!"
	installinnodb="n"
	;;
	*)
	echo "INPUT error,The InnoDB Storage Engine will NOT install!"
	installinnodb="n"
	esac

#which PHP Version do you want to install?
echo "==========================="

	isinstallphp53="n"
	echo "Install PHP 5.3.28,Please input y"
	echo "Install PHP 5.2.17,Please input n or press Enter"
	read -p "(Please input y or n):" isinstallphp53

	case "$isinstallphp53" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install PHP 5.3.28"
	isinstallphp53="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install PHP 5.2.17"
	isinstallphp53="n"
	;;
	*)
	echo "INPUT error,You will install PHP 5.2.17"
	isinstallphp53="n"
	esac

#which MySQL Version do you want to install?
echo "==========================="

	isinstallmysql55="n"
	echo "Install MySQL 5.5.37,Please input y"
	echo "Install MySQL 5.1.73,Please input n or press Enter"
	echo "Install MariaDB 5.5.37,Please input md"
	read -p "(Please input y , n or md):" isinstallmysql55

	case "$isinstallmysql55" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install MySQL 5.5.37"
	isinstallmysql55="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install MySQL 5.1.73"
	isinstallmysql55="n"
	;;
	md|MD|Md|mD)
	echo "You will install MariaDB 5.5.37"
	isinstallmysql55="md"
	;;
	*)
	echo "INPUT error,You will install MySQL 5.1.73"
	isinstallmysql55="n"
	esac

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start..."
	char=`get_char`

function InitInstall()
{
cat /etc/issue
uname -a
MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
echo -e "\n Memory is: ${MemTotal} MB "
apt-get update
apt-get remove -y apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common php5 php5-common php5-cgi php5-mysql php5-curl php5-gd
killall apache2
dpkg -l |grep mysql 
dpkg -P libmysqlclient15off libmysqlclient15-dev mysql-common 
dpkg -l |grep apache 
dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
dpkg -l |grep php 
dpkg -P php5 php5-common php5-cgi php5-mysql php5-curl php5-gd
apt-get purge `dpkg -l | grep php| awk '{print $2}'`

#Synchronization time
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

apt-get install -y ntpdate
ntpdate -u pool.ntp.org
date

#Disable SeLinux
if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
fi

apt-get update
apt-get autoremove -y
apt-get -fy install
apt-get install -y build-essential gcc g++ make
for packages in build-essential gcc g++ make cmake automake autoconf re2c wget cron bzip2 libzip-dev libc6-dev file rcconf flex vim nano bison m4 gawk less make cpp binutils diffutils unzip tar bzip2 libbz2-dev unrar p7zip libncurses5-dev libncurses5 libncurses5-dev libncurses5-dev libtool libevent-dev libpcre3 libpcre3-dev libpcrecpp0  libssl-dev zlibc openssl libsasl2-dev libltdl3-dev libltdl-dev libmcrypt-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev curl libcurl3 libmhash2 libmhash-dev libpq-dev libpq5 gettext libncurses5-dev libcurl4-gnutls-dev libjpeg-dev libpng12-dev libxml2-dev zlib1g-dev libfreetype6 libfreetype6-dev libssl-dev libcurl3 libcurl4-openssl-dev libcurl4-gnutls-dev mcrypt libcap-dev diffutils ca-certificates debian-keyring debian-archive-keyring;
do apt-get install -y $packages --force-yes;apt-get -fy install;apt-get -y autoremove; done

}


#InitInstall 2>&1 | tee /root/lnmp-install.log
CheckAndDownloadFiles 2>&1 | tee -a /root/lnmp-install.log
InstallDependsAndOpt 2>&1 | tee -a /root/lnmp-install.log
if [ "$isinstallmysql55" = "n" ]; then
	InstallMySQL51 2>&1 | tee -a /root/lnmp-install.log
elif [ "$isinstallmysql55" = "y" ]; then
	InstallMySQL55 2>&1 | tee -a /root/lnmp-install.log
else
	InstallMariaDB 2>&1 | tee -a /root/lnmp-install.log
fi
if [ "$isinstallphp53" = "n" ]; then
	InstallPHP52 2>&1 | tee -a /root/lnmp-install.log
else
	InstallPHP53 2>&1 | tee -a /root/lnmp-install.log
fi
InstallNginx 2>&1 | tee -a /root/lnmp-install.log
CreatPHPTools 2>&1 | tee -a /root/lnmp-install.log
AddAndStartup 2>&1 | tee -a /root/lnmp-install.log
CheckInstall 2>&1 | tee -a /root/lnmp-install.log