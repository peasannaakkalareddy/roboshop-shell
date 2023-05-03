app_user=roboshop
#script=$(realpath "$0")
#script_path=$(dirname "$script")
func_schema(){
  if [ "$schema_setup" == "mongo" ]; then
  echo -e "\e[36m>>>>>>>>> Copy MongoDB repo <<<<<<<<\e[0m"
  cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo

  echo -e "\e[36m>>>>>>>>> Install MongoDB Client <<<<<<<<\e[0m"
  yum install mongodb-org-shell -y

  echo -e "\e[36m>>>>>>>>> Load Schema <<<<<<<<\e[0m"
  mongo --host mongodb-dev.cskvsmi.online </app/schema/${component}.js
fi
}
if [ "$schema_setup" == "mysql" ]; then

echo -e "\e[36m>>>>>>>>> Install MySQL <<<<<<<<\e[0m"
yum install mysql -y

echo -e "\e[36m>>>>>>>>> Load Schema <<<<<<<<\e[0m"
mysql -h mysql-dev.cskvsmi.online -uroot -p${mysql_root_password}< /app/schema/${component}.sql
fi
func_app_prereq(){
  echo -e "\e[36m>>>>>>>>> Add Application User <<<<<<<<\e[0m"
  useradd ${app_user}

  echo -e "\e[36m>>>>>>>>> Create Application Directory <<<<<<<<\e[0m"
  rm -rf /app
  mkdir /app

  echo -e "\e[36m>>>>>>>>> Download App Content <<<<<<<<\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  cd /app

  echo -e "\e[36m>>>>>>>>> Unzip App Content <<<<<<<<\e[0m"
  unzip /tmp/${component}.zip
}
func_systemd(){
  echo -e "\e[36m>>>>>>>>> Copy ${component} SystemD file <<<<<<<<\e[0m"
  cp ${script_path}/${component}.service /etc/systemd/system/${component}.service

  echo -e "\e[36m>>>>>>>>> Start ${component} Service <<<<<<<<\e[0m"
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl restart ${component}
}
func_nodejs(){

echo -e "\e[36m>>>>>>>>> Configuring NodeJS repos <<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo -e "\e[36m>>>>>>>>> Install NodeJS <<<<<<<<\e[0m"
yum install nodejs -y

func_app_prereq

echo -e "\e[36m>>>>>>>>> Install NodeJS Dependencies <<<<<<<<\e[0m"
npm install
func_schema


}

func_java(){
  echo -e "\e[36m>>>>>>>>> Install Maven <<<<<<<<\e[0m"
  yum install maven -y

  func_app_prereq

  echo -e "\e[36m>>>>>>>>> Download Maven Dependencies <<<<<<<<\e[0m"
  mvn clean package
  mv target/shipping-1.0.jar shipping.jar
  schema_setup
  func_systemd
}

func_python() {
  echo -e "\e[36m>>>>>>>>> Install Python <<<<<<<<\e[0m"
  yum install python36 gcc python3-devel -y

  func_app_prereq

  echo -e "\e[36m>>>>>>>>> Install Dependencies <<<<<<<<\e[0m"

  pip3.6 install -r requirements.txt
  sed -i -e "s|rabbitmq_appuser_password|${rabbitmq_appuser_password}|" ${script_path}/payment.service
  func_systemd
}