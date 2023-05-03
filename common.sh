app_user=roboshop
#script=$(realpath "$0")
#script_path=$(dirname "$script")
logfile=/roboshop/log
func_print_head(){
  echo -e "\e[35m>>>>>>$1<<<<<<<<<<\e[0m"
}
func_schema(){
  if [ "$schema_setup" == "mongo" ]; then

  func_print_head " Copy MongoDB repo "
  cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>${logfile}

  func_print_head " Install MongoDB Client "
  yum install mongodb-org-shell -y &>${logfile}

  func_print_head " Load Schema "
  mongo --host mongodb-dev.cskvsmi.online </app/schema/${component}.js &>${logfile}
fi


if [ "$schema_setup" == "mysql" ]; then

func_print_head " Install MySQL "
yum install mysql -y &>${logfile}

func_print_head " Load Schema "
mysql -h mysql-dev.cskvsmi.online -uroot -p${mysql_root_password}< /app/schema/${component}.sql &>${logfile}
fi

}
func_app_prereq(){

  func_print_head " Add Application User "

  useradd ${app_user} &>${logfile}

  func_print_head " Create Application Directory "
  rm -rf /app &>${logfile}
  mkdir /app &>${logfile}

    func_print_head " Download App Content "
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>${logfile}
  cd /app &>${logfile}

  func_print_head " Unzip App Content "
  unzip /tmp/${component}.zip &>${logfile}
}
func_systemd(){
   func_print_head " Copy ${component} SystemD file "
  cp ${script_path}/${component}.service /etc/systemd/system/${component}.service &>${logfile}

  func_print_head " Start ${component} Service "

  systemctl daemon-reload &>${logfile}
  systemctl enable ${component} &>${logfile}
  systemctl restart ${component} &>${logfile}
}
func_nodejs(){

  func_print_head " Configuring NodeJS repos "
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>${logfile}

func_print_head " Install NodeJS "
yum install nodejs -y &>${logfile}

func_app_prereq
func_print_head " Install NodeJS Dependencies "
npm install &>${logfile}
func_schema


}

func_java(){
  func_print_head " Install Maven "
  yum install maven -y &>${logfile}

  func_app_prereq
    func_print_head " Download Maven Dependencies "

  mvn clean package &>${logfile}
  mv target/shipping-1.0.jar shipping.jar &>${logfile}
  func_schema
  func_systemd
}

func_python() {

      func_print_head " Install Python "

  yum install python36 gcc python3-devel -y &>${logfile}

  func_app_prereq

        func_print_head " Install Dependencies "


  pip3.6 install -r requirements.txt &>${logfile}
  sed -i -e "s|rabbitmq_appuser_password|${rabbitmq_appuser_password}|" ${script_path}/payment.service
  func_systemd
}