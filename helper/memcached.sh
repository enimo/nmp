#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install Memcached for NMP\n"
printf "=======================================================================\n"
cur_dir=$(pwd)

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
	echo "Press any key to start install Memcached..."
	char=`get_char`

printf "=========================== install memcached ======================\n"

echo "Install memcache php extension..."
wget -c http://soft.vpser.net/web/memcache/memcache-3.0.6.tgz
tar zxvf memcache-3.0.6.tgz
cd memcache-3.0.6/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

cur_php_version=`/usr/local/php/bin/php -v`

if echo "$cur_php_version" | grep -q "5.2."
then
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "memcache.so"\n#' /usr/local/php/etc/php.ini
elif echo "$cur_php_version" | grep -q "5.3."
then
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/"\nextension = "memcache.so"\n#' /usr/local/php/etc/php.ini
elif echo "$cur_php_version" | grep -q "5.4."
then
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/"\nextension = "memcache.so"\n#' /usr/local/php/etc/php.ini
fi

wget -c http://soft.vpser.net/lib/libevent/libevent-2.0.13-stable.tar.gz
tar zxvf libevent-2.0.13-stable.tar.gz
cd libevent-2.0.13-stable/
./configure --prefix=/usr/local/libevent
make&& make install
cd ../

echo "/usr/local/libevent/lib/" >> /etc/ld.so.conf
ln -s /usr/local/libevent/lib/libevent-2.0.so.5  /lib/libevent-2.0.so.5
ldconfig

cd $cur_dir
echo "Install memcached..."
wget -c http://soft.vpser.net/web/memcached/memcached-1.4.15.tar.gz
tar zxvf memcached-1.4.15.tar.gz
cd memcached-1.4.15/
./configure --prefix=/usr/local/memcached
make &&make install
cd ../

ln /usr/local/memcached/bin/memcached /usr/bin/memcached

cd $cur_dir
cp conf/memcached-init /etc/init.d/memcached
chmod +x /etc/init.d/memcached
useradd -s /sbin/nologin nobody

if [ -s /etc/debian_version ]; then
update-rc.d -f memcached defaults
elif [ -s /etc/redhat-release ]; then
chkconfig --level 345 memcached on
fi

echo "Copy Memcached PHP Test file..."
cp conf/memcached.php /home/wwwroot/memcached.php

echo "Starting Memcached..."
/etc/init.d/memcached start

printf "===================== install Memcached completed =====================\n"
printf "Install Memcached completed.\n"
printf "=======================================================================\n"