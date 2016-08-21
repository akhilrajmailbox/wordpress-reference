from torusware/speedus-ubuntu
maintainer akhil
run apt-get -y update
run apt-get -y install apache2

run apt-get -y install php5
run apt-get -y install libapache2-mod-php5
run apt-get -y install php5-gd
run apt-get -y install php5-curl
run apt-get -y install libssh2-php
run apt-get -y install rsync
run apt-get -y install php5-mysql
run apt-get -y install php5-fpm
run apt-get -y install openssh-client=1:6.6p1-2ubuntu1
run apt-get -y install git
run apt-get -y install unzip
run apt-get -y install nano
run mkdir /var/www/html/wordpress /home/apachefiles /etc/apache2/ssl

run sed -i "s|expose_php = On|expose_php = Off|g" /etc/php5/apache2/php.ini
run sed -i "s|allow_url_fopen = On|allow_url_fopen = Off|g" /etc/php5/apache2/php.ini

workdir /tmp
run git clone -b master https://github.com/akhilrajmailbox/biz-wp.git
workdir /tmp/biz-wp
run find /tmp/biz-wp/wp-content/plugins/*.zip -exec unzip {} \;
run rm -r /tmp/biz-wp/wp-content/plugins/*.zip

run cp /tmp/biz-wp/secure.conf /etc/apache2/sites-available/ && rm /tmp/biz-wp/secure.conf
run cp /tmp/biz-wp/redirection.conf /etc/apache2/sites-available/ && rm /tmp/biz-wp/redirection.conf
run cp /tmp/biz-wp/apache.crt /etc/apache2/ssl/ && rm /tmp/biz-wp/apache.crt
run cp /tmp/biz-wp/apache.key /etc/apache2/ssl/ && rm /tmp/biz-wp/apache.key

run cp wp-config-sample.php wp-config.php
run sed -i "s|define('DB_NAME', 'database_name_here');|define('DB_NAME', 'wordpress');|g" wp-config.php
run sed -i "s|define('DB_USER', 'username_here');|define('DB_USER', 'ubuntu');|g" wp-config.php
run sed -i "s|define('DB_PASSWORD', 'password_here');|define('DB_PASSWORD', 'ubuntu');|g" wp-config.php
run sed -i "s|define('DB_HOST', 'localhost');|define('DB_HOST', '192.168.1.234');|g" wp-config.php
run sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|g" /etc/php5/fpm/php.ini
run rsync -avP /tmp/biz-wp/ /var/www/html/wordpress/

workdir /root
run a2ensite secure.conf
run a2ensite redirection.conf
run a2enmod dir
run a2enmod ssl
run a2enmod rewrite
run a2dissite 000-default.conf
run chown -R www-data:www-data /var/www/html/
run chmod 755 -R /var/www/html/
expose 80 443
entrypoint service apache2 restart && service php5-fpm restart && bash
