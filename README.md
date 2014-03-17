# NMP (Nginx+MySQL+PHP+etc)

It's a script help you install nginx+mysql+php+fpm+etc in Linux.

Special for CentOS/RedHat, the rest OS without test. And It's not NPM(Nodejs package manager).



## Usage

### Install

You need clone this repos to your local directory first:

```
git clone https://github.com/enimo/nmp.git
```
And then execute "sh install.sh" as root user.

### Lanuch info

```
Nginx Launch：/etc/init.d/nginx {start|stop|reload|restart}
PHP-FPM Launch：/etc/init.d/php-fpm {start|stop|quit|restart|reload|logrotate}
MySQL Launch：/etc/init.d/mysql {start|stop|restart|reload|force-reload|status}
PHPInfo Access: http://yourIP/phpinfo.php
phpMyAdmin : http://yourIP/phpmyadmin/
Prober Test : http://yourIP/p.php
```

### Install Directory：

```
mysql :   /usr/local/mysql
php :     /usr/local/php
nginx :   /usr/local/nginx
Webroot Doc :     /home/bae/wwwroot
Nginx Log Dir：/home/bae/wwwlogs
```

### Config files：

```
Nginx main conf：/usr/local/nginx/conf/nginx.conf
MySQL conf：/etc/my.cnf
PHP conf：/usr/local/php/etc/php.ini
```
