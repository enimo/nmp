#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install nmp"
    exit 1
fi

clear
printf "=========================================================================\n"
printf "Manager Nginx+MySQL+PHP+FPM, based on LNMP.\n"
printf "Support CentOS/Redhat now...\n"
printf "=========================================================================\n"

cur_dir=$(pwd)

#set mysql root password
	echo "==========================="

	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default mysql password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
	echo "==========================="
	echo "MySQL root password:$mysqlrootpwd"
	echo "==========================="

#do you want to install the InnoDB Storage Engine?
echo "==========================="

	installinnodb="y"
	#事务型数据库的首选引擎，支持ACID事务，支持行级锁定。InnoDB是为处理巨大数据量时的最大性能设计。
	#InnoDB 给 MySQL 提供了具有事务(transaction)、回滚(rollback)和崩溃修复能力(crash recovery capabilities)、多版本并发控制(multi-versioned concurrency control)的事务安全(transaction-safe (ACID compliant))型表。
	#InnoDB是MySQL下使用最广泛的引擎，它是基于MySQL的高可扩展性和高性能存储引擎，从5.5版本开始，它已经成为了默认引擎。
	echo "Do you want to install the InnoDB Storage Engine?"
	read -p "(Default yes,if you want please input: y ,if not please press input: n):" installinnodb

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

	isinstallphp53="y"

#which MySQL Version do you want to install?
echo "==========================="

	isinstallmysql55="y"


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
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

function InitInstall()
{
	cat /etc/issue
	uname -a
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
	echo -e "\n Memory is: ${MemTotal} MB "
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	yum install -y ntp
	ntpdate -u pool.ntp.org
	date

	#rpm -qa|grep httpd
	#rpm -e httpd
	rpm -qa|grep mysql
	rpm -e mysql
	rpm -qa|grep php
	rpm -e php

	#yum -y remove httpd*
	yum -y remove php*
	yum -y remove mysql-server mysql
	yum -y remove php-mysql

	yum -y install yum-fastestmirror
	#yum -y remove httpd
	#yum -y update

	#Disable SeLinux
	if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	cp /etc/yum.conf /etc/yum.conf.nmp
	sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

	for packages in patch make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap;
	do yum -y install $packages; done

	mv -f /etc/yum.conf.nmp /etc/yum.conf
}

function CheckAndDownloadFiles()
{
echo "============================check files=================================="

if [ -s nginx-1.4.5.tar.gz ]; then
  echo "nginx-1.4.5.tar.gz [found]"
  else
  echo "Error: nginx-1.4.5.tar.gz not found!!!download now......"
  wget -c http://nginx.org/download/nginx-1.4.5.tar.gz
  #http://soft.vpser.net/web/nginx/nginx-1.2.7.tar.gz
fi

#从Vpser.net(VPSer Linux Software Download Center)下载稳定资源包
if [ "$isinstallmysql55" = "n" ]; then
	echo "[old version discard.]"
else
	if [ -s mysql-5.5.28.tar.gz ]; then
	  echo "mysql-5.5.28.tar.gz [found]"
	  else
	  echo "Error: mysql-5.5.28.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/mysql/mysql-5.5.28.tar.gz
	fi
fi

if [ "$isinstallphp53" = "n" ]; then

	echo "[old version discard.]"

else
	if [ -s php-5.3.17.tar.gz ]; then
	  echo "php-5.3.17.tar.gz [found]"
	else
	  echo "Error: php-5.3.17.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/web/php/php-5.3.17.tar.gz
	fi
fi

if [ -s phpMyAdmin-3.4.8-all-languages.tar.gz ]; then
  echo "phpMyAdmin-3.4.8-all-languages.tar.gz [found]"
  else
  echo "Error: phpMyAdmin-3.4.8-all-languages.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/datebase/phpmyadmin/phpMyAdmin-3.4.8-all-languages.tar.gz
  #http://soft.vpser.net/datebase/phpmyadmin/phpmyadmin-latest.tar.gz
fi

if [ -s memcache-3.0.6.tgz ]; then
  echo "memcache-3.0.6.tgz [found]"
  else
  echo "Error: memcache-3.0.6.tgz not found!!!download now......"
  wget -c http://soft.vpser.net/web/memcache/memcache-3.0.6.tgz
fi

if [ -s pcre-8.12.tar.gz ]; then
  echo "pcre-8.12.tar.gz [found]"
  else
  echo "Error: pcre-8.12.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/pcre/pcre-8.12.tar.gz
fi

if [ -s libiconv-1.14.tar.gz ]; then
  echo "libiconv-1.14.tar.gz [found]"
  else
  echo "Error: libiconv-1.14.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/libiconv/libiconv-1.14.tar.gz
fi

if [ -s libmcrypt-2.5.8.tar.gz ]; then
  echo "libmcrypt-2.5.8.tar.gz [found]"
  else
  echo "Error: libmcrypt-2.5.8.tar.gz not found!!!download now......"
  wget -c  http://soft.vpser.net/web/libmcrypt/libmcrypt-2.5.8.tar.gz
fi

if [ -s mhash-0.9.9.9.tar.gz ]; then
  echo "mhash-0.9.9.9.tar.gz [found]"
  else
  echo "Error: mhash-0.9.9.9.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/mhash/mhash-0.9.9.9.tar.gz
fi

if [ -s mcrypt-2.6.8.tar.gz ]; then
  echo "mcrypt-2.6.8.tar.gz [found]"
  else
  echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/mcrypt/mcrypt-2.6.8.tar.gz
fi


if [ -s autoconf-2.13.tar.gz ]; then
  echo "autoconf-2.13.tar.gz [found]"
  else
  echo "Error: autoconf-2.13.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/lib/autoconf/autoconf-2.13.tar.gz
fi
echo "============================check files=================================="
}

function InstallDependsAndOpt()
{
cd $cur_dir

tar zxvf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14/
./configure
make && make install
cd ../

cd $cur_dir
tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

cd $cur_dir
tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

cd $cur_dir
tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

cat >>/etc/sysctl.conf<<eof
fs.file-max=65535
eof
}


function InstallMySQL55()
{
echo "============================Install MySQL 5.5.26=================================="
cd $cur_dir

rm -f /etc/my.cnf
tar zxvf mysql-5.5.28.tar.gz
cd mysql-5.5.28/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
make && make install

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cp support-files/my-medium.cnf /etc/my.cnf
sed '/skip-external-locking/i\datadir = /usr/local/mysql/var' -i /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
else
sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
fi

/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/var --user=mysql
chown -R mysql /usr/local/mysql/var
chgrp -R mysql /usr/local/mysql/.
cp support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
if [ -d "/proc/vz" ];then
ulimit -s unlimited
fi
/etc/init.d/mysql start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart
/etc/init.d/mysql stop
echo "============================MySQL 5.5.26 install completed========================="
}


function InstallPHP53()
{
echo "============================Install PHP 5.3.17================================"
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxvf php-5.3.17.tar.gz
cd php-5.3.17/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
mkdir -p /usr/local/php/etc
cp php.ini-production /usr/local/php/etc/php.ini

cd $cur_dir
# php extensions
echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini

echo "Install ZendGuardLoader for PHP 5.3"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
else
	wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
fi

echo "Write ZendGuardLoader to php.ini......"
cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer] 
zend_extension=/usr/local/zend/ZendGuardLoader.so
EOF

echo "Creating new php-fpm configure file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
EOF

echo "Copy php-fpm init.d file......"
cp $cur_dir/php-5.3.17/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp $cur_dir/nmp /root/nmp
chmod +x /root/nmp
sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/nmp
echo "============================PHP 5.3.17 install completed======================"
}

function InstallNginx()
{
echo "============================Install Nginx================================="
groupadd www
useradd -s /sbin/nologin -g www www
cd $cur_dir
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

ldconfig

tar zxvf nginx-1.4.5.tar.gz
cd nginx-1.4.5/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

rm -f /usr/local/nginx/conf/nginx.conf
cd $cur_dir
cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
#cp conf/wordpress.conf /usr/local/nginx/conf/wordpress.conf

mv /usr/local/nginx/conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf.bak
cp conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf

cd $cur_dir
# cp vhost.sh /root/vhost.sh
# chmod +x /root/vhost.sh

mkdir -p /home/bae/wwwroot/main
chmod +w /home/bae/wwwroot/main
mkdir -p /home/bae/wwwlogs
chmod 777 /home/bae/wwwlogs

chown -R www:www /home/bae/wwwroot/main
}

function CreatPHPTools()
{
	echo "Create PHP Info Tool..."
cat >/home/bae/wwwroot/main/pt.php<<eof
<?
phpinfo();
?>
eof
chmod 755 /home/bae/wwwroot/main/pt.php

#复制PHP探针
echo "Copy PHP Prober..."
cd $cur_dir
cp conf/p.php /home/bae/wwwroot/main/p.php
chmod 755 /home/bae/wwwroot/main/p.php

#默认首页静态页
cp conf/index.html /home/bae/wwwroot/main/index.html
chmod 755 /home/bae/wwwroot/main/index.html
chown www:www -R /home/bae/wwwroot/main/

echo "============================Install PHPMyAdmin================================="
tar zxf phpMyAdmin-3.4.8-all-languages.tar.gz
mv phpMyAdmin-3.4.8-all-languages /home/bae/wwwroot/main/phpmyadmin/
cp conf/phpmyadmin.config.inc.php /home/bae/wwwroot/main/phpmyadmin/config.inc.php
#sed -i 's/NMP/focus.org'$RANDOM'bit.net/g' /home/bae/wwwroot/main/phpmyadmin/config.inc.php
mkdir /home/bae/wwwroot/main/phpmyadmin/upload/
mkdir /home/bae/wwwroot/main/phpmyadmin/save/
chmod 755 -R /home/bae/wwwroot/main/phpmyadmin/
chown www:www -R /home/bae/wwwroot/main/phpmyadmin/
echo "============================phpMyAdmin install completed================================="
}

function AddAndStartup()
{
echo "============================add nginx and php-fpm on startup============================"
cp $cur_dir/conf/init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

# chkconfig命令主要用来更新（启动或停止）和查询系统服务的运行级信息。
# 谨记chkconfig不是立即自动禁止或激活一个服务，它只是简单的改变了符号连接。
# --add   新增所指定的系统服务 	--del 删除所指定的系统服务
# --level 指定该系统服务要在哪个执行等级中开启或关闭 --list   列出当前可从chkconfig指令管理的所有系统服务和等级代号
# on/off/reset   在指定的执行登记,开启/关闭/重置该系统服务  
chkconfig --level 345 php-fpm on
chkconfig --level 345 nginx on
chkconfig --level 345 mysql on
echo "===========================add nginx and php-fpm on startup completed===================="

echo "Starting NMP..."
/etc/init.d/mysql start
/etc/init.d/php-fpm start
/etc/init.d/nginx start

#add 80 port to iptables
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables-save
fi
}

function CheckInstall()
{
echo "===================================== Check install ==================================="
clear
isnginx=""
ismysql=""
isphp=""
echo "Checking..."
if [ -s /usr/local/nginx ] && [ -s /usr/local/nginx/sbin/nginx ]; then
  echo "Nginx: OK"
  isnginx="ok"
  else
  echo "Error: /usr/local/nginx not found!! Nginx install failed."
fi

if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ]; then
  echo "PHP: OK"
  echo "PHP-FPM: OK"
  isphp="ok"
  else
  echo "Error: /usr/local/php not found!!!PHP install failed."
fi

if [ -s /usr/local/mysql ] && [ -s /usr/local/mysql/bin/mysql ]; then
  echo "MySQL: OK"
  ismysql="ok"
  else
  echo "Error: /usr/local/mysql not found!!!MySQL install failed."
fi
if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
	echo "Install NMP completed."
	echo "========================================================================="
	echo "Usage: /root/nmp {start|stop|reload|restart|kill|status}\n"
	echo "=========================================================================\n"
	echo "default mysql root password:$mysqlrootpwd"
	echo "phpinfo : http://yourIP/phpinfo.php"
	echo "phpMyAdmin : http://yourIP/phpmyadmin/"
	echo "Prober : http://yourIP/p.php"

	echo ""
	echo "The path of some dirs:"
	echo "mysql dir:   /usr/local/mysql, config dir: /usr/local/nginx/conf/nginx.conf"
	echo "php dir:     /usr/local/php, config dir: /usr/local/php/etc/php.ini"
	echo "nginx dir:   /usr/local/nginx, config dir: /usr/local/nginx/conf/nginx.conf"
	echo "web dir :     /home/bae/wwwroot/main"
	echo ""
	echo "========================================================================="
	/root/nmp status
	netstat -ntl
else
	echo "NMP install Failed!"
	echo "Check /root/nmp-install.log for debug."
fi
}

InitInstall 2>&1 | tee /root/nmp-install.log
CheckAndDownloadFiles 2>&1 | tee -a /root/nmp-install.log
InstallDependsAndOpt 2>&1 | tee -a /root/nmp-install.log

InstallMySQL55 2>&1 | tee -a /root/nmp-install.log
InstallPHP53 2>&1 | tee -a /root/nmp-install.log
InstallNginx 2>&1 | tee -a /root/nmp-install.log

CreatPHPTools 2>&1 | tee -a /root/nmp-install.log
AddAndStartup 2>&1 | tee -a /root/nmp-install.log

CheckInstall 2>&1 | tee -a /root/nmp-install.log