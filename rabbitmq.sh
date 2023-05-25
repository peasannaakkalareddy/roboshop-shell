script=$(realpath "$0")
script_path=$(dirname "$script")
source $script_path/common.sh
rabbitmq_appuser_password=$1
if [ -z "$rabbitmq_appuser_password" ]; then
  echo Input roboshop user password missing
  exit
fi

echo -e "\e[36m>>>>>>>>> Setup ErLang Repos <<<<<<<<\e[0m"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>${logfile}
func_status_check $?

echo -e "\e[36m>>>>>>>>> Setup RabbitMQ Repos <<<<<<<<\e[0m"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>${logfile}
func_status_check $?

echo -e "\e[36m>>>>>>>>> Install ErLang & RabbitMQ <<<<<<<<\e[0m"
yum install erlang rabbitmq-server -y &>${logfile}
func_status_check $?

echo -e "\e[36m>>>>>>>>> Start RabbitMQ Service <<<<<<<<\e[0m"
systemctl enable rabbitmq-server &>${logfile}
systemctl restart rabbitmq-server &>${logfile}
func_status_check $?

echo -e "\e[36m>>>>>>>>> Add Application User in RabbtiMQ <<<<<<<<\e[0m"
rabbitmqctl add_user roboshop ${rabbitmq_appuser_password} &>${logfile}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>${logfile}
func_status_check $?
