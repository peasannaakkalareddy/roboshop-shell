script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

echo -e "\e[35m>>>>>> copying repos <<<<<<<<<<\e[0m"
cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>${logfile}
func_status_check $?
echo -e "\e[35m>>>>>> install  mongodb-org <<<<<<<<<<\e[0m"
yum install mongodb-org -y &>${logfile}
func_status_check $?

sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/mongod.conf
echo -e "\e[35m>>>>>> enable mongod <<<<<<<<<<\e[0m"
systemctl enable mongod &>${logfile}
func_status_check $?
echo -e "\e[35m>>>>>> restart mongod <<<<<<<<<<\e[0m"
systemctl restart mongod &>${logfile}
func_status_check $?