script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

func_print_head " Install Nginx server "
yum install nginx -y &>>$logfile
func_status_check $?
func_print_head " Copy roboshop configuration file "
cp ${script_path}/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$logfile
func_status_check $?
func_print_head " Remove old app content "
rm -rf /usr/share/nginx/html/* &>>$logfile
func_status_check $?
func_print_head "  Download App Content "
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>$logfile
func_status_check $?
cd /usr/share/nginx/html &>>$logfile
func_print_head " Unzip App Content "
unzip /tmp/frontend.zip &>>$logfile
func_status_check $?
func_print_head " Start nginx Service "
systemctl restart nginx &>>$logfile
systemctl enable nginx &>>$logfile
func_status_check $?