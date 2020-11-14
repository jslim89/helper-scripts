#!/bin/bash
# Ref: https://medium.com/@dbclin/a-bash-script-to-update-an-existing-aws-security-group-with-my-new-public-ip-address-d0c965d67f28

helpFunction()
{
   echo ""
   echo "Usage: $0 -i 123.123.123.123 -g sg-1234567890abcdef -p 80"
   echo -e "\t-i The IP address you want to add to the security group (by default is your current IP)"
   echo -e "\t-g Security group ID"
   echo -e "\t-p The port number"
   exit 1 # Exit script after printing help
}

while getopts "i:g:p:" opt
do
   case "$opt" in
      i ) ip_addr="$OPTARG" ;;
      g ) sec_group_id="$OPTARG" ;;
      p ) port="$OPTARG" ;;
      ? ) helpFunction ;;
   esac
done

if [[ -z $sec_group_id ]] || [[ -z $port ]]; then
    helpFunction
fi

if [ -z $ip_addr ]; then
    json_ip=$(curl https://api.ipify.org/?format=json)
    ip_addr=`echo $json_ip | python3 -c "import sys, json; print(json.load(sys.stdin)['ip'])"`
fi
aws ec2 authorize-security-group-ingress --group-id $sec_group_id \
 --protocol tcp --port $port --cidr "$ip_addr/32"
