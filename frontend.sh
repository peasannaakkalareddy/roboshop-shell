script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

yum install nginx -y
cp ${app_user}.conf /etc/nginx/default.d/${app_user}.conf
rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://${app_user}-artifacts.s3.amazonaws.com/frontend.zip
cd /usr/share/nginx/html
unzip /tmp/frontend.zip
systemctl restart nginx
systemctl enable nginx