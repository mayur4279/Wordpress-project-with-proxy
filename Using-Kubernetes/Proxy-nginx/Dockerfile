FROM nginx:latest

#nginx Configuration  

ADD https://github.com/mayur4279/Wordpress-project-with-proxy/raw/main/Using-Kubernetes/nginx.conf   /etc/nginx/nginx.conf

#  log rotation script  

ADD  https://github.com/mayur4279/Wordpress-project-with-proxy/raw/main/Using-Kubernetes/Proxy-nginx/nginx /etc/logrotate.d/nginx  

ADD https://github.com/mayur4279/Wordpress-project-with-proxy/raw/main/Using-Kubernetes/Proxy-nginx/nginx_log_analysis.sh /usr/local/bin/nginx_log_analysis.sh  

RUN chmod +x /usr/local/bin/nginx_log_analysis.sh

RUN echo "* * * * * /usr/local/bin/nginx_log_analysis.sh" | sudo tee -a /tmp/crontab_new


EXPOSE 80  
