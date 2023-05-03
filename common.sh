app_user=roboshop
#script=$(realpath "$0")
#script_path=$(dirname "$script")
logfile=/tmp/roboshop.log

func_print_head(){
  echo -e "\e[35m>>>>>>$1<<<<<<<<<<\e[0m"
}
func_status_check (){
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSuccess\e[0m"
    else
      echo -e "\e[31mFailure\e[0m"
      echo " Refer the log file /tmp/roboshop.log for more info "
      exit 1
  fi
}
func_schema(){
  if [ "$schema_setup" == "mongo" ]; then

  func_print_head " Copy MongoDB repo "
  cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>${logfile}
  func_status_check $?

  func_print_head " Install MongoDB Client "
  yum install mongodb-org-shell -y &>${logfile}
  func_status_check $?

  func_print_head " Load Schema "
  mongo --host mongodb-dev.cskvsmi.online </app/schema/${component}.js &>${logfile}
  func_status_check $?
fi


if [ "$schema_setup" == "mysql" ]; then

func_print_head " Install MySQL "
yum install mysql -y &>${logfile}
func_status_check $?

func_print_head " Load Schema "
mysql -h mysql-dev.cskvsmi.online -uroot -p${mysql_root_password}< /app/schema/${component}.sql &>${logfile}
func_status_check $?
fi

}
func_app_prereq(){

  func_print_head " Add Application User "

  id ${app_user} &>${logfile}

  if [ $? -ne 0 ]; then
    useradd ${app_user}  &>${logfile}
  fi

  func_status_check $?

  func_print_head " Create Application Directory "
  rm -rf /app &>${logfile}
  func_status_check $?
  mkdir /app &>${logfile}
  func_status_check $?

    func_print_head " Download App Content "
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>${logfile}
  cd /app &>${logfile}
  func_status_check $?

  func_print_head " Unzip App Content "
  unzip /tmp/${component}.zip &>${logfile}
  func_status_check $?
}
func_systemd(){
   func_print_head " Copy ${component} SystemD file "
  cp ${script_path}/${component}.service /etc/systemd/system/${component}.service &>${logfile}
  func_status_check $?

  func_print_head " Start ${component} Service "

  systemctl daemon-reload &>${logfile}
  func_status_check $?
  systemctl enable ${component} &>${logfile}
  func_status_check $?
  systemctl restart ${component} &>${logfile}
  func_status_check $?
}
func_nodejs(){

  func_print_head " Configuring NodeJS repos "
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>${logfile}
func_status_check $?

func_print_head " Install NodeJS "
yum install nodejs -y &>${logfile}
func_status_check $?

func_app_prereq
func_print_head " Install NodeJS Dependencies "
npm install &>${logfile}
func_status_check $?
func_schema


}

func_java(){
  func_print_head " Install Maven "
  yum install maven -y &>${logfile}
  func_status_check $?

  func_app_prereq
    func_print_head " Download Maven Dependencies "

  mvn clean package &>${logfile}
  func_status_check $?
  mv target/shipping-1.0.jar shipping.jar &>${logfile}
  func_status_check $?
  func_schema
  func_systemd
}

func_python() {

      func_print_head " Install Python "

  yum install python36 gcc python3-devel -y &>${logfile}
  func_status_check $?

  func_app_prereq

        func_print_head " Install Dependencies "


  pip3.6 install -r requirements.txt &>${logfile}
   func_status_check $?
  sed -i -e "s|rabbitmq_appuser_password|${rabbitmq_appuser_password}|" ${script_path}/payment.service &>${logfile}
  func_status_check $?
  func_systemd
}