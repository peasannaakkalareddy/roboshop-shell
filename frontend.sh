script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

  echo -e "\e[35m>>>>>> Install nginx <<<<<<<<<<\e[0m"

yum install nginx -y &>${logfile}
func_status_check $?
echo -e "\e[35m>>>>>> copying conf file <<<<<<<<<<\e[0m"
cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>${logfile}
func_status_check $?
echo -e "\e[35m>>>>>> removing default temp <<<<<<<<<<\e[0m"
rm -rf /usr/share/nginx/html/* &>${logfile}
func_status_check $?
echo -e "\e[35m>>>>>> downloading app packages <<<<<<<<<<\e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>${logfile}
func_status_check $?
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>${logfile}
echo -e "\e[35m>>>>>> restart nginx <<<<<<<<<<\e[0m"
systemctl restart nginx &>${logfile}
func_status_check $?
echo -e "\e[35m>>>>>> enable nginx <<<<<<<<<<\e[0m"
systemctl enable nginx &>${logfile}
func_status_check $?