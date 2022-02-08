#bin/bash
#======================
#User Input:
#============


#======================
# Install LEMP
#===============
sudo apt update -y
sudo apt install nginx mysql-server php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
sudo systemctl restart php7.4-fpm
sudo mysql_secure_installation
sudo mkdir /var/www/blog
sudo mkdir /var/www/portfolio
sudo chown -R $USER:$USER /var/www/
sudo touch /etc/nginx/sites-available/halim.website
sudo echo "
server {
    listen 80;
    server_name wp.halim.website www.wp.halim.website;
    root /var/www/blog;

    index index.html index.htm index.php;

    location / {
        #try_files $uri $uri/ =404;
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }
    
    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt { log_not_found off; access_log off; allow all; }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }

}
" > /etc/nginx/sites-available/halim.website

sudo ln -s /etc/nginx/sites-available/halim.website /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

#=========================================
#Install Certificate
#=====================
sudo apt install certbot python3-certbot-nginx -y
sudo certbot run -n --nginx --agree-tos -d halim.website,www.halim.website  -m  ah.hesham93@gmail.com  --redirect
sudo systemctl reload nginx

#=================================================================
#Create WordPress DB Details
#============================

mysql --user="root" --password="$mysql_password_root" --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$mysql_password_root';"
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost';

#==============================
#Git
#=====
sudo git clone git@github.com:haliim/HalimBlog.git /var/www/blog
sudo chown -R www-data:www-data /var/www/

#===============================
#Download wordpress:
#====================

cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sudo cp -a /tmp/wordpress/. /var/www/blog
sudo chown -R www-data:www-data /var/www/
curl -s https://api.wordpress.org/secret-key/1.1/salt/
sudo nano /var/www/blog/wp-config.php
