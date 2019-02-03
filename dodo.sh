#!/bin/bash


LOG_DIR=./log
INIT_LOG=$LOG_DIR/init_master.log


##################################
# Interfaces to DigitalOcean API #
##################################


auth_chk() {
        jq . $INIT_LOG | awk -F "id\":" '{print $2}' | cut -d '"' -f2 | grep -i unauthorized >> /dev/null
        [[ $? == 0 ]] && echo "Error: Unauthorized! Please check your DigitalOcean token and try again " && exit 13
}

case "$1" in 
	 up)

	NAME=$2
	TAG=$3
	curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $(cat ./secrets/token)" -d "$(. ./master.sh $NAME $TAG)" "https://api.digitalocean.com/v2/droplets" > $INIT_LOG
	MASTER_DROPLET_ID=$(cat $INIT_LOG | jq ".droplet.id")
	auth_chk
	if [[ -z $MASTER_DROPLET_ID ]]
	then
		echo "Error: Unable to fetch master droplet ID. Exiting..."
		exit 13
	fi
	echo -e " I am spinning up a node. This may take some time. Sleeping for 30 secs then moving on."
	for i in {1..30}; do echo -ne "$i\r"; sleep 1; done
	echo -e "Nap time over. Moving on...."

	curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $(cat ./secrets/token)" "https://api.digitalocean.com/v2/droplets/$MASTER_DROPLET_ID" >> $INIT_LOG
	MASTER_DROPLET_IPV4=$(cat $INIT_LOG | jq ".droplet.networks.v4"  | cut -d { -f1 | grep ip_address | cut -d : -f2- | cut -d \" -f2) # don't know why JQ complains 

	echo "Your server should be ready: try ssh root@$MASTER_DROPLET_IPV4"
	
	# screen -dmS alba ./albatross.sh $MASTER_DROPLET_IPV4
	;;

	destroy)

	echo -e "Destroying all droplets with the label $2"
	curl -s -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $(cat ./secrets/token)" "https://api.digitalocean.com/v2/droplets?tag_name=$2" 
	echo -e "Done"

	;;

	*)
	
	echo -e "Usage: dodo {up|destroy} droplet_name [tagname]"
	;;
esac
