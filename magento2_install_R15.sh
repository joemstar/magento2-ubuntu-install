##########################################
### MAGENTO 2 & WORDPRESS INSTALLATION ###
### REVISION: 15                       ###
##########################################


## Set Defaults ##
php_version=7.4
magento_base_url=MyMagentoSite.com
magento_root=MyMagentoSite.com
wordpress_base_url=MyWordpressSite.com
wordpress_root=MyWordpressSite.com
date_timezone=America/New_York
current_date_time=$(date)

echo Script Started: ${current_date_time} - "$0" | sudo tee -a /root/pw.txt

## Set The System TimeZone ##
sudo timedatectl set-timezone ${date_timezone}

## Check for System Updates ##
setterm -term linux -foreground cyan
echo "Check for and Install System Updates? [Y,n]"
setterm -term linux -foreground white
read system_update
if [ "$system_update" != "${system_update#[Yy]}" ] ;then
	setterm -term linux -foreground green
	echo "Checking for updates..."
    setterm -term linux -foreground yellow
    sudo apt-get update -y
    echo
	setterm -term linux -foreground green
    echo "Installing updates..."
	sudo apt-get upgrade -y
    echo
    echo "Managing the repositories that you install software from..."
    sudo apt-get install software-properties-common -y
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "System Update was skipped."
    setterm -term linux -foreground white
fi

## Install Webmin ##
setterm -term linux -foreground cyan
echo "Install Webmin? [Y,n]"
setterm -term linux -foreground white
read webmin_install
if [ "$webmin_install" != "${webmin_install#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Installing Webmin..."
	wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] http://download.webmin.com/download/repository sarge contrib"
	sudo apt-get install webmin -y
    sudo service webmin restart
	sudo systemctl status webmin --no-pager
	echo "Webmin Installed"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Webmin installation was skipped."
    setterm -term linux -foreground white
fi


## Install Nginx Webserver ##
setterm -term linux -foreground cyan
echo "Install Nginx Web Server? [Y,n]"
setterm -term linux -foreground white
read nginx_install
if [ "$nginx_install" != "${nginx_install#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Installing Nginx..."
	sudo apt-get install nginx -y
	sudo systemctl start nginx
	sudo systemctl enable --now nginx
	sudo systemctl status nginx --no-pager
    sudo rm nginx-0.11.wbm_.gz
	echo "Nginx Web Server Installed"
    setterm -term linux -foreground white
    
    ## Install Webmin Nginx Webserver Module##
    setterm -term linux -foreground cyan
	echo "Install Nginx webserver Module for Webmin? [Y,n]"
	setterm -term linux -foreground white
	read webmin_nginx_install
	if [ "$webmin_nginx_install" != "${webmin_nginx_install#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Installing Nginx webserver Module..."
    	sudo apt install libhtml-parser-perl -y
    	sudo wget -c https://www.justindhoffman.com/sites/justindhoffman.com/files/nginx-0.11.wbm_.gz && sudo tar -xzf  nginx-0.11.wbm_.gz -C /usr/share/webmin/ 
        sudo mkdir /etc/webmin/nginx
        sudo tee /etc/webmin/nginx/config  <<END
start_cmd=1
nginx_path=/usr/sbin/nginx
max_servers=30
nginx_version=
test_config=1
show_order=0
pid_file=
nginx_conf=/etc/nginx/nginx.conf
virt_name=
stop_cmd=1
test_nginx=1
mime_types=/etc/nginx/mime.types
link_dir=/etc/nginx/sites-enabled
apply_cmd=2
nginx_dir=/etc/nginx
virt_dir=/etc/nginx/sites-available
messages=
END
        
        sudo systemctl restart webmin
    	echo "Nginx webserver Module Installed"
    	setterm -term linux -foreground white
	else
    	setterm -term linux -foreground red
    	echo "Nginx webserver Module installation was skipped."
    	setterm -term linux -foreground white
	fi
    
else
    setterm -term linux -foreground red
    echo "Nginx Web Server installation was skipped."
    setterm -term linux -foreground white
fi


## Install and Configure PHP-FPm ##
setterm -term linux -foreground cyan
echo "Install PHP and set required settings for Magento? [Y,n]"
setterm -term linux -foreground white
read php_install
if [ "$php_install" != "${php_install#[Yy]}" ] ;then
    setterm -term linux -foreground cyan
	read -e -p "Enter PHP version: " -i "7.4" php_version
	setterm -term linux -foreground green
    echo "Installing PHP ${php_version}..."
	sudo add-apt-repository ppa:ondrej/php -y
	sudo apt install php${php_version}-fpm php${php_version}-common php${php_version}-curl php${php_version}-cli php${php_version}-mysql php${php_version}-gd php${php_version}-xml php${php_version}-json php${php_version}-intl php-pear php${php_version}-dev php${php_version}-common php${php_version}-mbstring php${php_version}-zip php${php_version}-soap php${php_version}-bcmath php${php_version}-opcache -y
    #php -v
    echo "PHP ${php_version} Installed"
    
    
    sudo systemctl start php${php_version}-fpm
	sudo systemctl enable --now php${php_version}-fpm
	sudo ss -xa | grep php
    sudo systemctl status php${php_version}-fpm --no-pager
    
    echo
    echo "Restarting Nginx..."
    sudo service nginx restart
    
    
    
    ## Add php.ini to Webmin PHP Configuration Module##
    setterm -term linux -foreground cyan
	echo "Add PHP ${php_version} to Webmin PHP Configuration Module? [Y,n]"
	setterm -term linux -foreground white
	read webmin_phpini_install
	if [ "$webmin_phpini_install" != "${webmin_phpini_install#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Adding PHP ${php_version} to Webmin PHP Configuration..."
    	sudo sed -i '/^php_ini=/ s/$/ \t\/etc\/php\/'"${php_version}"'\/fpm\/php.ini=Configuration for scripts run via fpm \t\/etc\/php\/'"${php_version}"'\/cli\/php.ini=Configuration for command-line scripts/' /etc/webmin/phpini/config
      	echo "PHP ${php_version} Added to Webmin PHP Configuration Module"
    	setterm -term linux -foreground white
	else
    	setterm -term linux -foreground red
    	echo "Adding PHP ${php_version} to Webmin PHP Configuration Module was skipped."
    	setterm -term linux -foreground white
	fi
    
    setterm -term linux -foreground white    
else
    setterm -term linux -foreground red
    echo "PHP installation was skipped."
    setterm -term linux -foreground white
fi 
   
## Install Database Engine ##
setterm -term linux -foreground cyan
echo "Install Database Engine? [Y,n]"
read dbengine_install
if [ "$dbengine_install" != "${dbengine_install#[Yy]}" ] ;then
	setterm -term linux -foreground yellow
    echo "You may be asked to create a password for the database root user during installation."
    echo "REMEMBER THIS PASSWORD. IT WILL BE NEEDED LATER IN THIS INSTALLATION."
	setterm -term linux -foreground green
	read -e -p "Select Database Engine [percona,mariadb]}: " -i "percona" dbengine_name
	if [ "$dbengine_name" == "percona" ] ;then
		setterm -term linux -foreground green
    	echo "Installing Percona Database Engine..."
		sudo apt-get install gnupg2 -y
		sudo wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
		sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
		sudo percona-release setup ps80
		sudo apt-get install percona-server-server -y
		sudo systemctl start mysql
		sudo systemctl enable --now mysql
		sudo systemctl status mysql --no-pager
        sudo rm percona-release_latest.focal_all.deb
	    echo "Percona Database Engine Installed"
	    setterm -term linux -foreground white    
    
    elif  [ "$dbengine_name" == "mariadb" ] ;then
    	setterm -term linux -foreground green
    	echo "Installing MariaDB Database Engine..."
		sudo apt install mariadb-server -y
		sudo systemctl start mariadb
		sudo systemctl enable --now mariadb
		sudo systemctl status mariadb --no-pager
    	echo "MariaDB Database Engine Installed"
    	setterm -term linux -foreground white   
  	else
	    setterm -term linux -foreground red
	    echo "Database Engine installation was skipped."
	    setterm -term linux -foreground white
	fi
    
    ## Secure the Installation ##
    setterm -term linux -foreground green
    echo
    echo "Securing the MySQL server deployment..."
    echo
    #setterm -term linux -foreground magenta
    #echo "ANSWER THE FOLLOWING QUESTIONS WITH THESE RESPONSES"
    #echo "Set a root password? [Y/n] Y"
	#echo "Remove anonymous users? [Y/n] Y"
	#echo "Disallow root login remotely? [Y/n] Y"
	#echo "Remove test database and access to it? [Y/n] Y"
	#echo "Reload privilege tables now? [Y/n] Y"
    #setterm -term linux -foreground cyan
    #echo
    #mysql_secure_installation
    #setterm -term linux -foreground green
    
   	setterm -term linux -foreground cyan
	#echo "Please Please enter root user MySQL password!!"
	#read root_password    
    #echo
    #root_password=$(openssl rand 12 | openssl base64 -A | tr -d "=+/")
	#read -e -p "Enter a new root user MySQL password: " -i "${root_password}" root_password
    read -s -p "Enter your root user MySQL password (password will be hidden when typing):" root_password
    echo
   	setterm -term linux -foreground green
    # If /root/.my.cnf exists then use the root password
	if [ -f /root/.my.cnf ]; then
		sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}';"
	# If /root/.my.cnf doesn't exist then use the root password   
	else
   		sudo mysql -uroot -p${root_password} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}';"
    fi
    echo "Root Password Set"
    echo "MySql Root User: root" | sudo tee -a /root/pw.txt
    echo "MySql Root Password: ${root_password}" | sudo tee -a /root/pw.txt
    sudo mysql -uroot -p${root_password} -e "DELETE FROM mysql.user WHERE User='';"    
	echo "Anonymous Users Removed"
    sudo  mysql -uroot -p${root_password} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	echo "Remote Root Login Disallowed"
    sudo mysql -uroot -p${root_password} -e "DROP DATABASE IF EXISTS test;"
    sudo mysql -uroot -p${root_password} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    echo "Test Database And Access To It Have Been Removed"
    sudo mysql -uroot -p${root_password} -e "FLUSH PRIVILEGES;"
    echo "Privilege Tables Have  Been Reloaded"
    echo
    echo "MySQL server deployment secured..."

    
else
    setterm -term linux -foreground red
    echo "Database Engine installation was skipped."
    setterm -term linux -foreground white
fi
    


## Configure MySQL Database Server Module for Webmin ##
setterm -term linux -foreground cyan
echo "Configure MySQL Database Server Module for Webmin? [Y,n]"
setterm -term linux -foreground white
read mysql_webmin
if [ "$mysql_webmin" != "${mysql_webmin#[Yy]}" ] ;then
setterm -term linux -foreground green
echo "Configuring MySQL Database Server Module for Webmin..."
    sudo cp /etc/webmin/mysql/config /etc/webmin/mysql/config.BACK
    sudo sed -i 's/.*my_cnf.*/my_cnf=\/etc\/mysql\/my.cnf/' /etc/webmin/mysql/config
    echo "MySQL Database Server Module for Webmin Configured"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "MySQL Database Server Module for Webmin Configuration was skipped."
    setterm -term linux -foreground white
fi
        


## Install phpMyAdmin ##
setterm -term linux -foreground yellow
echo "During the phpMyAdmin installation, you will be asked to select the web server."
echo "Since we are using the Nginx web server, press the TAB key, and then ENTER to bypass this prompt."
setterm -term linux -foreground cyan
echo "Install phpMyAdmin? [Y,n]"
setterm -term linux -foreground white
read phpmyadmin_install
if [ "$phpmyadmin_install" != "${phpmyadmin_install#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Installing phpMyAdmin..."
	sudo apt install phpmyadmin -y -q
    
sudo tee /etc/nginx/snippets/phpmyadmin.conf  <<END
location /phpmyadmin {
    root /usr/share/;
    index index.php index.html index.htm;
    location ~ ^/phpmyadmin/(.+\.php)\$ {
        try_files \$uri =404;
        root /usr/share/;
        fastcgi_pass unix:/run/php/php${php_version}-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include /etc/nginx/fastcgi_params;
    }

    location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {
        root /usr/share/;
    }
}
END
	echo "phpMyAdmin Installed"
    echo "Restarting Nginx..."
	sudo nginx -t
	sudo systemctl restart nginx
	sudo systemctl status nginx --no-pager
else
    setterm -term linux -foreground red
    echo "phpMyAdmin installation was skipped."
    setterm -term linux -foreground white
fi


## Install Elasticsearch ##
setterm -term linux -foreground cyan
echo "Install Elasticsearch? [Y,n]"
setterm -term linux -foreground white
read elasticsearch_install
if [ "$elasticsearch_install" != "${elasticsearch_install#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Installing ElasticSearch..."
	wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
	sudo apt-get install apt-transport-https
	echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt-get update -y
	sudo apt-get install elasticsearch -y
    sudo /bin/systemctl daemon-reload
	sudo /bin/systemctl enable --now elasticsearch.service
	sudo curl -X GET "localhost:9200/"
	sudo systemctl status elasticsearch --no-pager
	echo "ElasticSearch Installed"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "ElasticSearch installation was skipped."
    setterm -term linux -foreground white
fi



## Download and Install Magento 2.4 ##
setterm -term linux -foreground cyan
echo "Install Magento 2.4? [Y,n]"
setterm -term linux -foreground white
read magento_install
if [ "$magento_install" != "${magento_install#[Yy]}" ] ;then

	## Install Composer ##
	setterm -term linux -foreground cyan
	echo "Install Composer? [Y,n]"
	setterm -term linux -foreground white
	read composer_install
	if [ "$composer_install" != "${composer_install#[Yy]}" ] ;then
		setterm -term linux -foreground green
	    echo "Installing Composer..."
		sudo apt install composer -y
		composer --version
		echo "Composer Installed"
	    setterm -term linux -foreground white
	else
	    setterm -term linux -foreground red
	    echo "Composer installation was skipped."
	    setterm -term linux -foreground white
	fi

    ## Create Magento Database ##
    setterm -term linux -foreground cyan
	echo "Create Magento Database and user? [Y,n]"
	setterm -term linux -foreground white
	read magentodb_install
	if [ "$magentodb_install" != "${magentodb_install#[Yy]}" ] ;then
    magentodb_password=$(openssl rand 12 | openssl base64 -A | tr -d "=+/")
	read -e -p "Enter a new password for magentouser for magentodb: " -i "${magentodb_password}" magentodb_password
	setterm -term linux -foreground green
    echo "Creating Magento Database and user..."    
#mysql -u root -p <<EOF
#CREATE DATABASE magentodb;
#CREATE USER magentouser@'localhost' IDENTIFIED BY '${magentodb_password}';
#GRANT ALL PRIVILEGES ON magentodb.* to magentouser@'localhost'WITH GRANT OPTION;
#FLUSH PRIVILEGES;
#exit
#EOF
	
	setterm -term linux -foreground cyan
	#echo "Please enter root user MySQL password!"
	#read root_password
    #read -s -p "Enter your root user MySQL password (password will be hidden when typing):" root_password
    read -e -p "Enter your root user MySQL password: " -i "${root_password}" root_password
   	sudo mysql -uroot -p${root_password} -e "CREATE DATABASE magentodb;"
    sudo mysql -uroot -p${root_password} -e "CREATE USER magentouser@'localhost' IDENTIFIED BY '${magentodb_password}';"
    sudo mysql -uroot -p${root_password} -e "GRANT ALL PRIVILEGES ON magentodb.* TO magentouser@'localhost';"
    sudo mysql -uroot -p${root_password} -e "FLUSH PRIVILEGES;"
     
    echo "Magento Database Name: magentodb" | sudo tee -a /root/pw.txt
    echo "Magento Database User: magentouser" | sudo tee -a /root/pw.txt
    echo "Magento Database Password: ${magentodb_password}" | sudo tee -a /root/pw.txt
    
	setterm -term linux -foreground green
    	echo "Magento Database and User Created."
    	setterm -term linux -foreground white
	else
    	setterm -term linux -foreground red
    	echo "Magento Database and User Creation was skipped."
    	setterm -term linux -foreground white
	fi


    setterm -term linux -foreground green
    ## Make a Backup of php.ini ##
    echo
    echo "Creating a back-up of php.ini..."    
    sudo cp /etc/php/${php_version}/fpm/php.ini /etc/php/${php_version}/fpm/php.ini.BACK
    
    ## Configure php.ini ##
    echo
    echo "Configuring php.ini for Magento..."
    
    setterm -term linux -foreground cyan
	read -e -p "Enter Your Time Zone: " -i "${date_timezone}" date_timezone
    sudo sed -i 's/memory_limit = .*/memory_limit = 2048M/' /etc/php/${php_version}/fpm/php.ini
	sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 256M/' /etc/php/${php_version}/fpm/php.ini
	sudo sed -i 's/zlib.output_compression = .*/zlib.output_compression = on/' /etc/php/${php_version}/fpm/php.ini
	sudo sed -i 's/;cgi.fix_pathinfo = .*/cgi.fix_pathinfo = 0/' /etc/php/${php_version}/fpm/php.ini
	sudo sed -i 's/max_execution_time = .*/max_execution_time = 18000/' /etc/php/${php_version}/fpm/php.ini
	sudo sed -i "s/;date.timezone.*/date.timezone = ${date_timezone//\//\\/}/" /etc/php/${php_version}/fpm/php.ini
	sudo sed -i 's/;opcache.enable.*/opcache.enable = 1/' /etc/php/${php_version}/fpm/php.ini
	sudo sed -i 's/;opcache.save_comments.*/opcache.save_comments = 1/' /etc/php/${php_version}/fpm/php.ini

    setterm -term linux -foreground green
    echo "PHP ${php_version} Parameters Configured"
	echo
    echo "Preparing to Install Magento..."
    setterm -term linux -foreground cyan
    read -e -p "Enter your PHP Version: " -i "${php_version}"  php_version
	read -e -p "Enter your Base Url: " -i "${magento_base_url}"  magento_base_url
	read -e -p "Enter your Database Host: " -i "localhost"  magentodb_host
	read -e -p "Enter your Database Name: " -i "magentodb"  magentodb_name
	read -e -p "Enter your Database User: " -i "magentouser"  magentodb_user
	read -e -p "Enter your Database Password: " -i "${magentodb_password}"  magentodb_password
	read -e -p "Enter your Admin First Name: " -i "FirstName"  magento_admin_firstname
	read -e -p "Enter your Admin Last Name: " -i "LastName"  magento_admin_lastname
	read -e -p "Enter your Admin email: " -i "admin@${magento_base_url}"  magento_admin_email
	read -e -p "Enter your Admin user name: " -i "admin"  magento_admin_user
	#read -e -p "Enter your Admin password: " -i ""  magento_admin_password
    magento_admin_password=$(openssl rand 12 | openssl base64 -A | tr -d "=+/")
	read -e -p "Enter a new password for Magento Admin: " -i "${magento_admin_password}" magento_admin_password
	read -e -p "Enter your Language: " -i "en_US"  magento_language
	read -e -p "Enter your Currency: " -i "USD"  magento_currency
	read -e -p "Enter your Time Zone: " -i "${date_timezone}"  date_timezone
    magento_root=${magento_base_url}
    read -e -p "Enter Magento docroot for installation : " -i "${magento_root}"  magento_root
    
    echo
	read -e -p "Enter Magento 2.x version: " -i "2.4" magento_version
	setterm -term linux -foreground yellow
    echo "Downloading Magento ${magento_version}..."
	cd /var/www/html/
	sudo composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${magento_version} ${magento_base_url}
	cd /var/www/html/${magento_root}/
	sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
	sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
	sudo chown -R :www-data . # Ubuntu
	sudo chmod u+x bin/magento
	setterm -term linux -foreground green
    echo "Installing Magento ${magento_version}..."
	sudo bin/magento setup:install --base-url=https://${magento_base_url} \
    --db-host=${magentodb_host} \
    --db-name=${magentodb_name} \
    --db-user=${magentodb_user} \
    --db-password=${magentodb_password} \
    --admin-firstname=${magento_admin_firstname} \
    --admin-lastname=${magento_admin_lastname} \
    --admin-email=${magento_admin_email} \
    --admin-user=${magento_admin_user} \
    --admin-password=${magento_admin_password} \
    --language=${magento_language} \
    --currency=${magento_currency} \
    --timezone=${date_timezone} \
    --use-rewrites=1
    
    echo "Magento Admin User: ${magento_admin_user}" | sudo tee -a /root/pw.txt
    echo "Magento Admin Password: ${magento_admin_password}" | sudo tee -a /root/pw.txt
    magento_admin_uri=$(sudo php /var/www/html/${magento_root}/bin/magento info:adminuri)
    magento_admin_uri=$(echo $magento_admin_uri | sed -e 's/\r//g')
    echo "Magento ${magento_admin_uri}" | sudo tee -a /root/pw.txt
    
	sudo bin/magento module:disable Magento_TwoFactorAuth
	sudo bin/magento cache:flush
    
    ## Setup Magento CRON ##
    echo "Setting Up Magento CRON job..."
    cd /var/www/html/${magento_root}
	sudo -u www-data php bin/magento cron:install --force
	sudo crontab -u www-data -l
	sudo chmod u-w /var/www/html/${magento_root}/app/etc
	cd   
    
    echo "Creating Magento Virtual Host..."
    sudo tee /etc/nginx/sites-available/${magento_base_url}  <<END
upstream fastcgi_backend {
server  unix:/run/php/php${php_version}-fpm.sock;
}

server {
	listen 80;
    server_name ${magento_base_url} www.${magento_base_url};
    
    set \$MAGE_ROOT /var/www/html/${magento_root};
   	set \$MAGE_MODE developer; # or production
    
    include /var/www/html/${magento_root}/nginx.conf.sample;
    include snippets/phpmyadmin.conf;    
    
    access_log /var/log/nginx/${magento_base_url}-access.log;
    error_log /var/log/nginx/${magento_base_url}-error.log;
    
}
END

    echo "Enabling Magento Nginx virtualhost..."
	sudo ln -s /etc/nginx/sites-available/${magento_base_url} /etc/nginx/sites-enabled/
	sudo nginx -t
    echo "Restarting Nginx..."
	sudo systemctl restart nginx
	sudo systemctl status nginx --no-pager
    
	echo "Magento Installed"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Magento 2.4 installation was skipped."
    setterm -term linux -foreground white
fi

cd

## Generate SSL Letsencrypt ##
setterm -term linux -foreground cyan
echo "Generate SSL Letsencrypt for Magento? [Y,n]"
setterm -term linux -foreground white
read ssl_generate_magento
if [ "$ssl_generate_magento" != "${ssl_generate_magento#[Yy]}" ] ;then
	setterm -term linux -foreground cyan
    read -e -p "Enter your PHP Version: " -i "${php_version}"  php_version
    read -e -p "Enter your Base Url: " -i "${magento_base_url}"  magento_base_url
	read -e -p "Enter your Admin email: " -i "admin@${magento_base_url}"  magento_admin_email
    magento_root=${magento_base_url}
    read -e -p "Enter Magento docroot: " -i "${magento_root}"  magento_root
	setterm -term linux -foreground green
    echo "Installing Certbot Tool..."
	#sudo apt install certbot
    sudo apt-get install certbot python3-certbot-nginx -y
    echo "Generating SSL Letsencrypt..."
    sudo systemctl stop nginx
	sudo certbot certonly --standalone --agree-tos --no-eff-email --email ${magento_admin_email} -d ${magento_base_url} -d www.${magento_base_url} 
    echo "Updating Magento Virtual Host to use SSL..."
        sudo tee /etc/nginx/sites-available/${magento_base_url}  <<END
upstream fastcgi_backend {
server  unix:/run/php/php${php_version}-fpm.sock;
}

server {
	listen 80;
    server_name ${magento_base_url} www.${magento_base_url};
    return 301 https://\$server_name\$request_uri;
}

server {
	listen 443 ssl http2;
    server_name ${magento_base_url} www.${magento_base_url};
    
	ssl_certificate /etc/letsencrypt/live/${magento_base_url}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${magento_base_url}/privkey.pem; 
    
    set \$MAGE_ROOT /var/www/html/${magento_root};
   	set \$MAGE_MODE developer; # or production
    
    include /var/www/html/${magento_root}/nginx.conf.sample;
    include snippets/phpmyadmin.conf;
    
    
    access_log /var/log/nginx/${magento_base_url}-access.log;
    error_log /var/log/nginx/${magento_base_url}-error.log;
}
END

	sudo nginx -t
    echo "Restarting Nginx..."
	sudo systemctl restart nginx
	sudo systemctl status nginx --no-pager

	echo "SSL Letsencrypt Installed"
    

	setterm -term linux -foreground cyan
	echo "Configure Webmin to Use Letsencrypt? [Y,n]"
	setterm -term linux -foreground white
	read webmin_cert
	if [ "$webmin_cert" != "${webmin_cert#[Yy]}" ] ;then
		setterm -term linux -foreground green
    	echo "Configuring Webmin to Use Letsencrypt..."
	    sudo sed -i "s/keyfile=.*/keyfile=\/etc\/letsencrypt\/live\/${magento_base_url}\/privkey.pem/" /etc/webmin/miniserv.conf
        echo "certfile=/etc/letsencrypt/live/${magento_base_url}/fullchain.pem/" | sudo tee -a /etc/webmin/miniserv.conf
	    sudo sed -i "s/certfile=.*/certfile=\/etc\/letsencrypt\/live\/${magento_base_url}\/fullchain.pem/" /etc/webmin/miniserv.conf
		echo "Webmin configured to Use Letsencrypt"
    	setterm -term linux -foreground white
	else
    	setterm -term linux -foreground red
    	echo "Configure Webmin to Use Letsencrypt was skipped."
    	setterm -term linux -foreground white
	fi
    
    
	setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Generation of SSL Letsencrypt was skipped."
    setterm -term linux -foreground white
fi


## Install Redis Cache ##
setterm -term linux -foreground cyan
echo "Install Redis for Magento? [Y,n]"
setterm -term linux -foreground white
read redis_install
if [ "$redis_install" != "${redis_install#[Yy]}" ] ;then
	setterm -term linux -foreground cyan
	read -e -p "Enter your Base Url: " -i "${magento_base_url}"  magento_base_url
    magento_root=${magento_base_url}
    read -e -p "Enter Magento docroot: " -i "${magento_root}"  magento_root
	setterm -term linux -foreground green
    echo "Installing Redis..."
	sudo apt-get install redis-server -y
    sudo update-rc.d redis-server defaults
    redis_password=$(openssl rand 60 | openssl base64 -A | tr -d "=+/")
    sudo sed -i "s/requirepass .*/requirepass ${redis_password}/" /etc/redis/redis.conf
    sudo sed -i "s/# requirepass .*/requirepass ${redis_password}/" /etc/redis/redis.conf
    echo "Redis Password: ${redis_password}" | sudo tee -a /root/pw.txt
    systemctl stop redis.service
    systemctl start redis.service
    systemctl enable --now redis.service
    systemctl status redis.service --no-pager
    
    cd /var/www/html/${magento_root}/
    
    echo "Configuring Magento for Redis default caching..."
    sudo bin/magento setup:config:set \
    --cache-backend=redis \
    --cache-backend-redis-server=127.0.0.1 \
    --cache-backend-redis-db=0 \
    --cache-backend-redis-password=${redis_password}
    
    echo "Configuring Magento for Redis page caching..."
    sudo bin/magento setup:config:set \
    --page-cache=redis \
    --page-cache-redis-server=127.0.0.1 \
    --page-cache-redis-db=1 \
    --page-cache-redis-password=${redis_password}    

    echo "Configuring Magento to use Redis for session storage..."
    sudo bin/magento setup:config:set \
    --session-save=redis \
    --session-save-redis-host=127.0.0.1 \
    --session-save-redis-log-level=4 \
    --session-save-redis-db=2 \
    --session-save-redis-password=${redis_password}
    
    cd
    
	echo "Redis Installed"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Redis installation was skipped."
    setterm -term linux -foreground white
fi

## Install Varnish Cache ##
setterm -term linux -foreground cyan
echo "Install Varnish Cache for Magento? [Y,n]"
setterm -term linux -foreground white
read varnishcache_install
if [ "$varnishcache_install" != "${varnishcache_install#[Yy]}" ] ;then
	setterm -term linux -foreground cyan
    read -e -p "Enter your PHP Version: " -i "${php_version}"  php_version
    read -e -p "Enter your Base Url: " -i "${magento_base_url}"  magento_base_url
    magento_root=${magento_base_url}
    read -e -p "Enter Magento docroot: " -i "${magento_root}"  magento_root
	setterm -term linux -foreground green
    echo "Installing Varnish Cache..."
    sudo curl -s https://packagecloud.io/install/repositories/varnishcache/varnish64/script.deb.sh | sudo bash
	sudo apt-get install varnish -y
    sudo systemctl --now enable varnish.service
    sudo systemctl start varnish
	sudo systemctl status varnish --no-pager
    varnishd -V
    echo "Configuring Magento to use Varnish Cache for Full Page Cache..."
    sudo mv /etc/varnish/default.vcl /etc/varnish/default.vcl.BACK
    # Download the Varnish vcl file from Magento
    sudo php /var/www/html/${magento_root}/bin/magento varnish:vcl:generate --export-version=6 --output-file=/etc/varnish/default.vcl
    # Correct an error in the Magento vcl pointing to the wrong path
    sudo sed -i 's/.url = "\/pub\/health_check.php";/.url = "\/health_check.php";/' /etc/varnish/default.vcl
    # Configure Magentoto use Varnish Cache
    sudo php /var/www/html/${magento_root}/bin/magento config:set system/full_page_cache/caching_application 2
    sudo php /var/www/html/${magento_root}/bin/magento config:set system/full_page_cache/varnish/access_list localhost
	sudo php /var/www/html/${magento_root}/bin/magento config:set system/full_page_cache/varnish/backend_host localhost
	sudo php /var/www/html/${magento_root}/bin/magento config:set system/full_page_cache/varnish/backend_port 8080
    
    echo "Updating Magento Virtual Host to use Varnish Cache with SSL..."
        sudo tee /etc/nginx/sites-available/${magento_base_url}  <<END
upstream fastcgi_backend {
server  unix:/run/php/php${php_version}-fpm.sock;
}

server {
	listen 80;
    server_name ${magento_base_url} www.${magento_base_url};
    return 301 https://\$server_name\$request_uri;
}

server {
	listen 443 ssl http2;
    server_name ${magento_base_url} www.${magento_base_url};
    
	ssl_certificate /etc/letsencrypt/live/${magento_base_url}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${magento_base_url}/privkey.pem; 
    
    include snippets/phpmyadmin.conf;
    
	location / {
	    proxy_pass http://127.0.0.1:6081;
	    proxy_set_header X-Real-IP  \$remote_addr;
	    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	    proxy_set_header X-Forwarded-Proto https;
	   	proxy_set_header X-Forwarded-Port 443;
 	   	proxy_set_header Host \$host;
        fastcgi_buffers 16 16k;
		fastcgi_buffer_size 32k;
		proxy_buffer_size 128k;
		proxy_buffers 4 256k;
		proxy_busy_buffers_size 256k;
        
    }    
    
    access_log /var/log/nginx/${magento_base_url}-access.log;
    error_log /var/log/nginx/${magento_base_url}-error.log;
}

server {
	listen 127.0.0.1:8080;
    server_name ${magento_base_url} www.${magento_base_url};

   	set \$MAGE_ROOT /var/www/html/${magento_root};
   	set \$MAGE_MODE developer; # or production
    
    include /var/www/html/${magento_root}/nginx.conf.sample;
    

}    
END
    echo "Restarting Varnish Cache Service..."
    sudo systemctl restart varnish
    echo "Restarting Nginx Web Server Service..."
    sudo systemctl restart nginx
    # go to magento folder and flush the cache
    echo "Flushing Magento Cache..."
	sudo /var/www/html/${magento_root}/bin/magento cache:flush
	echo "Varnish Cache Installed"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Varnish Cache Installation was skipped."
    setterm -term linux -foreground white
fi



## Download and Install Wordpress ##
setterm -term linux -foreground cyan
echo "Install Wordpress? [Y,n]"
setterm -term linux -foreground white
read wordpress_install
if [ "$wordpress_install" != "${wordpress_install#[Yy]}" ] ;then


    ## Create Wordpress Database ##
    setterm -term linux -foreground cyan
	echo "Create Wordpress Database and user? [Y,n]"
	read wordpressdb_install
	if [ "$wordpressdb_install" != "${wordpressdb_install#[Yy]}" ] ;then
   	wordpressdb_password=$(openssl rand 12 | openssl base64 -A | tr -d "=+/")
	read -e -p "Enter a new password for wordpressuser for wordpressdb: " -i "${wordpressdb_password}" wordpressdb_password
 	setterm -term linux -foreground green
    echo "Creating Wordpress Database and user..."    
#mysql -u root -p <<EOF
#CREATE DATABASE wordpressdb;
#CREATE USER wordpressuser@'localhost' IDENTIFIED BY '${wordpressdb_password}';
#GRANT ALL PRIVILEGES ON wordpressdb.* to wordpressuser@'localhost'WITH GRANT OPTION;
#FLUSH PRIVILEGES;
#exit
#EOF

	setterm -term linux -foreground cyan
	#echo "Please enter root user MySQL password!"
	#read root_password
    #read -s -p "Enter your root user MySQL password (password will be hidden when typing):" root_password
    read -e -p "Enter your root user MySQL password: " -i "${root_password}" root_password
   	sudo mysql -uroot -p${root_password} -e "CREATE DATABASE wordpressdb;"
    sudo mysql -uroot -p${root_password} -e "CREATE USER wordpressuser@'localhost' IDENTIFIED BY '${wordpressdb_password}';"
    sudo mysql -uroot -p${root_password} -e "GRANT ALL PRIVILEGES ON wordpressdb.* TO wordpressuser@'localhost';"
    sudo mysql -uroot -p${root_password} -e "FLUSH PRIVILEGES;"
    
    echo "Wordpress Database Name: wordpressdb" | sudo tee -a /root/pw.txt
    echo "Wordpress Database User: wordpressuser" | sudo tee -a /root/pw.txt
    echo "Wordpress Database Password: ${wordpressdb_password}" | sudo tee -a /root/pw.txt


	setterm -term linux -foreground green
    	echo "Wordpress Database and User Created."
    	setterm -term linux -foreground white
	else
    	setterm -term linux -foreground red
    	echo "Wordpress Database and User Creation was skipped."
    	setterm -term linux -foreground white
	fi



    setterm -term linux -foreground cyan
    read -e -p "Enter your PHP Version: " -i "${php_version}"  php_version
	read -e -p "Enter your Wordpress Base Url: " -i "${wordpress_base_url}"  wordpress_base_url
    wordpress_root=${wordpress_base_url}
    read -e -p "Enter Wordpress docroot for installation : " -i "${wordpress_root}"  wordpress_root
    
    echo "Downloading Wordpress..."
    sudo wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz    
	setterm -term linux -foreground green
    
    echo "Installing Wordpress..."
	sudo tar -xzvf /tmp/wordpress.tar.gz -C /var/www/html
    sudo mv /var/www/html/wordpress /var/www/html/${wordpress_root}
    sudo chown -R www-data.www-data /var/www/html/${wordpress_root}
      
    echo "Creating Wordpres Virtual Host..."
    sudo tee /etc/nginx/sites-available/${wordpress_base_url}  <<END
server {
    listen 80;
    server_name ${wordpress_base_url} www.${wordpress_base_url};
    root /var/www/html/${wordpress_root};
    
    index index.php;    

    include snippets/phpmyadmin.conf;
    
    location / {
		try_files \$uri \$uri/ =404;
    }

	location ~ \.php\$ {
    	include snippets/fastcgi-php.conf;
    	fastcgi_pass unix:/var/run/php/php${php_version}-fpm.sock;
    }
    
    access_log /var/log/nginx/${wordpress_base_url}-access.log;
    error_log /var/log/nginx/${wordpress_base_url}-error.log;
}
END

    echo "Enabling Wordpress Nginx virtualhost..."
	sudo ln -s /etc/nginx/sites-available/${wordpress_base_url} /etc/nginx/sites-enabled/
	sudo nginx -t
    echo "Restarting Nginx..."
	sudo systemctl restart nginx
	sudo systemctl status nginx --no-pager
    
	echo "Wordpress Installed. Visit ${wordpress_base_url} to complete the installation."
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Wordpress installation was skipped."
    setterm -term linux -foreground white
fi

## Generate SSL Letsencrypt ##
setterm -term linux -foreground cyan
echo "Generate SSL Letsencrypt for Wordpress? [Y,n]"
setterm -term linux -foreground white
read ssl_generate_wordpress
if [ "$ssl_generate_wordpress" != "${ssl_generate_wordpress#[Yy]}" ] ;then
	setterm -term linux -foreground cyan
    read -e -p "Enter your PHP Version: " -i "${php_version}"  php_version
    read -e -p "Enter your Base Url: " -i "${wordpress_base_url}"  wordpress_base_url
	read -e -p "Enter your Admin email: " -i "admin@${wordpress_base_url}"  wordpress_admin_email
    wordpress_root=${wordpress_base_url}
    read -e -p "Enter Wordpress docroot: " -i "${wordpress_root}"  wordpress_root
	setterm -term linux -foreground green
    echo "Installing Certbot Tool..."
	#sudo apt install certbot
    sudo apt-get install certbot python3-certbot-nginx -y
    echo "Generating SSL Letsencrypt..."
    sudo systemctl stop nginx
	sudo certbot certonly --standalone --agree-tos --no-eff-email --email ${wordpress_admin_email} -d ${wordpress_base_url} -d www.${wordpress_base_url} 
    echo "Updating Wordpress Virtual Host to use SSL..."
        sudo tee /etc/nginx/sites-available/${wordpress_base_url}  <<END
server {
    listen 80;
    server_name ${wordpress_base_url}  www.${wordpress_base_url} ;
    return 301 https://\$server_name\$request_uri;
}

server {

	listen 443 ssl http2;
    server_name ${wordpress_base_url}  www.${wordpress_base_url} ;
    
    root /var/www/html/${wordpress_root};
    
    index index.php;    
    
    include snippets/phpmyadmin.conf;

	ssl_certificate /etc/letsencrypt/live/${wordpress_base_url}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${wordpress_base_url}/privkey.pem;

    location / {
		try_files \$uri \$uri/ =404;
    }

	location ~ \.php\$ {
    	include snippets/fastcgi-php.conf;
    	fastcgi_pass unix:/var/run/php/php${php_version}-fpm.sock;
    }
    
    access_log /var/log/nginx/${wordpress_base_url}-access.log;
    error_log /var/log/nginx/${wordpress_base_url}-error.log;
}

END

	sudo nginx -t
    echo "Restarting Nginx..."
	sudo systemctl restart nginx
	sudo systemctl status nginx --no-pager

	echo "SSL Letsencrypt for Wordpress Installed"
   
	setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Generation of SSL Letsencrypt for Wordpress was skipped."
    setterm -term linux -foreground white
fi






## Configure and Enable UFW firewall ##
setterm -term linux -foreground cyan
echo "Enable UFW Firewall? [Y,n]"
setterm -term linux -foreground white
read firewall_enable
if [ "$firewall_enable" != "${firewall_enable#[Yy]}" ] ;then
	setterm -term linux -foreground green
    echo "Enabling Firewall..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
	sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw allow 10000/tcp ##For Webmin
    sudo ufw enable
    sudo ufw status verbose
	echo "UFW Firewall Enabled"
    setterm -term linux -foreground white
else
    setterm -term linux -foreground red
    echo "Enabling Firewall was skipped."
    setterm -term linux -foreground white
fi

setterm -term linux -foreground green
echo
echo "Installation Complete!"
setterm -term linux -foreground yellow
echo "Usernames and Passwords have been saved to /root/pw.txt"
current_date_time=$(date)
echo Script Completed: ${current_date_time} - "$0" | sudo tee -a /root/pw.txt
echo "" | sudo tee -a /root/pw.txt
setterm -term linux -foreground white
