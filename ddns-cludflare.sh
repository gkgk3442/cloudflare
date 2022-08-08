#!/bin/bash

### CloudFlare A Recoard Updater by varins.com
### A_Record : Separate the contents with commas (,)
### Proxied : true or false
### TTL : Between 120 and 2147483647 seconds, or 1 for automatic
### To force updating, run with -f

API_URI="https://api.cloudflare.com/client/v4/zones"
Login_Email="아이디"
Global_API_Key="키"
Domain="shinssy.com"
A_Record="레코드"
Proxied=false
TTL=1
PREV_IP_FILE="/tmp/ddns-ip.txt"

### v1.0.9 Published on 17 June 2020

CIP=$(curl -s "https://ipecho.net/plain/")
PIP=$(cat $PREV_IP_FILE)
echo -e "CloudFlare A Recoard Updater v1.0.9"
echo -e "Current IP: $CIP"
echo -e "Previous IP: $PIP"

if [ "$CIP" == "$PIP" ] && [[ $1 != "-f" ]]; then
  echo "No need to update"; exit 0
elif [[ $1 == "-f" ]]; then
  echo "Force updating A recoard......"
elif [ "$CIP" != "$PIP" ]; then
  echo "Updating A recoard......"
fi

rm -rf $PREV_IP_FILE
echo $CIP >> $PREV_IP_FILE

V4="$API_URI"
H1="-HX-Auth-Email:$Login_Email"
H2="-HX-Auth-Key:$Global_API_Key"
H3="-HContent-Type:application/json"
ZN=$(curl -s -X GET "$V4?name=$Domain" \
    $H1 $H2 $H3 | grep -Po '(?<="id":")[^"]*' | head -1)

string=$A_Record
IFS=',' ARARY=(${string})

function AID() {
  for AREC in "${ARARY[@]}"
    do
      (curl -s -X GET "$V4/$ZN/dns_records?name=$AREC" \
      $H1 $H2 $H3 | grep -Po '(?<="id":")[^"]*' | head -1)
    done
}

IFS=$'\n' AIDARY=($(AID))

ATOTAL=${#ARARY[*]}

for ((i=0; i<$ATOTAL; i++))
  do
    (curl -s -X PUT "$V4/$ZN/dns_records/${AIDARY[$i]}" $H1 $H2 $H3 \
    --data "{\"type\":\"A\",\"name\":\"${ARARY[$i]}\",\"content\":\"$CIP\",\"proxied\":$Proxied,\"ttl\":$TTL}" \
    | grep -Po '(?<="name":")[^"]*|(?<="content":")[^"]*|(?<=Z"},)[^}]*|(?<="success":false,)[^$]*|(?<=\s\s)[^$]*' | xargs)
  done
