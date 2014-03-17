# NMP

NMP just another web server shell script which integrated Nginx, MySQL, PHP and some other open source server package. It can help you install nginx+mysql+php+fpm+etc service easily in Linux.
Special for CentOS/RedHat, the rest OS without test. P.S.: It's not NPM(Nodejs package manager).



## Usage

### Install

You need clone this repos to your local directory first:

```
git clone https://github.com/enimo/nmp.git
```
And then execute "sh install.sh" as root user.

### Launch info

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
