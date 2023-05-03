script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
component=payment
rabbit_appuser_password=$1
if [ -z "$rabbit_appuser_password" ]; then
  echo rabbit appuser  password is missing
  exit
  fi
func_python