script=$(realpath "$0")
script_path=$(dirname "$script")
source $script_path/common.sh

echo -e "\e[36m>>>>>>>>> Install Redis Repos <<<<<<<<\e[0m"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>${logfile}
func_status_check $?
echo -e "\e[36m>>>>>>>>> Install Redis <<<<<<<<\e[0m"
dnf module enable redis:remi-6.2 -y
yum install redis -y &>${logfile}
func_status_check $?

echo -e "\e[36m>>>>>>>>> Update Redis Listen Address <<<<<<<<\e[0m"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/redis.conf /etc/redis/redis.conf &>${logfile}
func_status_check $?

echo -e "\e[36m>>>>>>>>> Start Redis Service <<<<<<<<\e[0m"
systemctl enable redis
systemctl restart redis &>${logfile}
func_status_check $?