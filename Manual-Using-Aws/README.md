# Wordpress-with-proxy (manual method)
### Problem statemant:- 
The problem statement requires deploying a sample WordPress website, protecting it with a **Nginx reverse proxy**, and allowing **admin login from a specific IP address only**.Additionally, the candidate must **enable log rotation**, **write a script to analyze Nginx logs**, and provide a report.They must also automate the deployment using either cloud infrastructure automation technology or containers.

### Table of Contents
1. [Requirements](#requirements)
2. [Step 1: Installing WordPress on Ubuntu OS](#step-1-installing-wordpress-on-ubuntu-os)
3. [Step 2: Reverse Proxy Setup Using Nginx](#step-2-reverse-proxy-setup-using-nginx)
4. [Step 3: Enabling Log Rotation](#step-3-enabling-log-rotation)
5. [Step 4: Allowing Admin Login from a Specific IP Address Only](#step-4-allowing-admin-login-from-a-specific-ip-address-only)
6. [Step 5: Security Tips](#step-5-security-tips)

### Requirements  
- Ubuntu os  for wordpress installtion
- Apache2 Web server
- php
- mariadb-server
- Nginx proxy server for clients
- Nginx proxy server for Admin only login  


### Step-1 Installing Wordpress on ubuntu os 

1. Launch the ubuntu instance
2. Update your Instance
   ```  bash 
   sudo apt update -y 
   ```
3. Download  the wordpress  
   ```
   wget https://wordpress.org/latest.zip
   ```
4. unzip  the zip file
   ```
   sudo apt install unzip  -y  
   unzip  latest.zip
   ```
5. Download  and setup apache2  Web server
   ```
   sudo apt install apache2 -y  
   sudo  systemctl  start apache2
   sudo  systemctl  enable apache2
   ```
6. Download The php with  supported packages
   ```
   sudo apt install php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
   ```
   
7. Next, move the extracted WordPress directory to the /var/www/html directory:
   ```
   sudo mv  wordpress  /var/www/html
   ```
8. Install  Mariadb server
   ```
   sudo apt install mariadb-server
   sudo mysql_secure_installation   (Type All Y for secure installation and Create password for root user)  
   ```
9. Create a Wordpress Database
   ```
   sudo mysql  -u root  -p
   CREATE DATABASE wordpress;
   exit; 
   ```
10. Create a user for wordpress and grant all privileges 
    ```
    CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'admin@123';
    grant all privileges on *.* to wpuser@localhost identified by 'admin@123' with grant option; 
    FLUSH PRIVILEGES; 
    ```
11. Configure Wordpress Using following command
    ```
    sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
    ```

12. Next, open the WordPress configuration file
    ```
    sudo vi /var/www/html/wordpress/wp-config.php
    ```
13. Next, update the database name, user, and password
    <br/>   
    <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/4da19c4e-017a-4a18-a251-ba0ccb268fdf" alt="Image" width="600">
    <br/>


15. Now Save and close The file
    <br/>
16. Setup  Wordpress <br/>
    Navigate to the following url
    ```
    http://18.119.116.243/wordpress/wp-admin/install.php
    ``` 
17. Next, Enter the Site Title, Username, Password, and Email Address for your Website

18. Successfully installed the wordpress on  ubuntu  server
    <br/>
    
    <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/fcacb5ac-9f18-48bb-b6d1-91daac2baaa8" alt="Image" width="600">
    
    <br/>


19. If we want  to  access our website using only  ip-address enter below commands 
    ```
    cd  /etc/apache2/sites-available
    sudo sed -i 's|/var/www/html|/var/www/html/wordpress|g' 000-default.conf
    sudo systemctl  restart apache2  
    ```
20. Successfully  accessed website using  only ip address  
    <br/>
    <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/4fb7b8b5-6ed5-489d-8395-5d8c09e13318" alt="Image" width="600">
    <br/>

### Step-2 Reverse Proxy Setup Using Nginx

1. Launch Any instance (used amazon ec2 linux)   
2. Download nginx
   ```
   sudo yum install nginx -y
   ```
3. Configure /etc/nginx/nginx.conf  file from below code  
   ```
      location / {
        proxy_pass  http://172.31.3.42;    #private ip of ubuntu instance
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_redirect off;
        proxy_buffering off;
 
        proxy_set_header        Host            $host;
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      }
      location ~ ^/(wp-admin|wp-login\.php) {
           deny all;
           proxy_pass  http://172.31.3.42;   #private ip of ubuntu instance 
      }
    ```
4. Start and Enable nginx  service
   ```
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

5. Successfully accessed website using nginx proxy
   <br/>
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/5c65fdfe-b849-4a3c-adc7-7c1d07bb6fc5" alt="Image" width="600">
   <br/> 

6. Through proxy Normal user cannot access the Admin login page **(wp-admin)**
   <br/>
   
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/84acbf5f-f335-4c6c-9d2d-6251ea67ab40" alt="Image" width="600">
   
   <br/>


### Step-3 Enabling Log Rotation 
#### This configurtaion is done In proxy server (nginx) 
1. Create log Rotation configuration file 
   ```
   sudo nano /etc/logrotate.d/nginx
   ```
2. Add the following configuration
   ```
    /var/log/nginx/*.log {
      daily
      missingok
      rotate 14
      compress
      delaycompress
      notifempty
      create 0640 www-data adm
      sharedscripts
      postrotate
          [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
      endscript
      } 
   ```
3. Create a Log Analysis Script
   ```
   sudo nano /usr/local/bin/nginx_log_analysis.sh
   ```
4. Add the following code
   ```bash 
   #!/bin/bash
   LOG_FILE="/var/log/nginx/access.log"
   REPORT_FILE="/var/log/nginx/report.log"

   echo "Nginx Log Analysis Report" > $REPORT_FILE
   echo "=========================" >> $REPORT_FILE
   echo "" >> $REPORT_FILE

   echo "Top 10 IP addresses:" >> $REPORT_FILE
   awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
   echo "" >> $REPORT_FILE

   echo "Top 10 requested URLs:" >> $REPORT_FILE
   awk '{print $7}' $LOG_FILE | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
   echo "" >> $REPORT_FILE

   echo "Top 10 user agents:" >> $REPORT_FILE
   awk -F\" '{print $6}' $LOG_FILE | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
   echo "" >> $REPORT_FILE
   
   echo "Response codes summary:" >> $REPORT_FILE
   awk '{print $9}' $LOG_FILE | grep -Eo '^[0-9]{3}' | sort | uniq -c | sort -nr >> $REPORT_FILE

   echo "Report generated at $(date)" >> $REPORT_FILE
   ```
5. Give permission to the file
   ```
   sudo chmod +x /usr/local/bin/nginx_log_analysis.sh
   ```
6. Schedule the Script with Cron
   ```
   sudo crontab -e
   ```
7. Add the follwing line for to run the script Daily
   ```
   0 0 * * * /usr/local/bin/nginx_log_analysis.sh
   #For running the script in every minutes use below script  
   #* * * * * /usr/local/bin/nginx_log_analysis.sh  
   ```
8. Now we we successfully get the report of the Nginx logs  
   ```
   cat  /var/log/nginx/report.log  
   ```


### Step-4 Allowing admin login from a specific IP address only

1. Create seperate proxy instance for Admin access (used amazon ec2 linux )
   <br/>
   
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/72443523-4d8f-4680-bec0-edf09a5ae612" alt="Image" width="600">
   
   <br/>

2. Download nginx
   ```
   sudo yum install nginx -y
   ```
3. Configure /etc/nginx/nginx.conf  file from below code  
   ```
      location / {
        proxy_pass  http://172.31.3.42; #private ip  of  ubuntu instance (main wordpress instance ) 
      }
    ```
4. Start and Enable nginx  service
   ```
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```
5. Edit the security group **(Assign the public ip of Admin)**
   <br/>  
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/75c1791e-84ef-45a9-8d1d-b8fbcefeb3c5" alt="Image" width="800">
   <br/>



6. Now Only Admin can access the Wordpress login page
   <br/>
   
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/4d0b7028-7a11-4f47-b423-e2c7ed3f056e" alt="Image" width="700">
   
   <br/>



### Step-5 Security Tips
- Create Private subnet For main wordpress instance instance (private subnet means we are not assigning the Internet Gateway (IGW) in Route Table )
- Create Public Subnet For proxy instance (public Subnet means we are assigning the Internet Gateway (IGW) in Route Table )
- Create Two Route Table with name public and private
- Assing IGW in public route table
- Do Not Assign IGW in Private route table

   <br/>
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/95ceaa7c-ac12-4c10-841f-99d957e2cadb" alt="Image" width="700">
   <br/>
   <br/>
   <img src="https://github.com/mayur4279/Wordpress-project-with-proxy/assets/73772313/8303024e-cef2-40fa-8a87-a32beecf13f0" alt="Image" width="700">   
   <br/>








