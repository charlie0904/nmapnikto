#!/bin/bash
echo -n
#awk '{for(i=1;i<=NF;i++)if($i~"/open/"){sub("/.*","",$i); print $2" port:" $i" opened"}}' $1.output
function usage {
	#echo "Usage: $1 [-f nmap.grepable] [-i IP] [-p port] [-s service] [-P protocol] [-a]"
	echo "Usage: $1 [-f nmap.grepable]"
	#echo "  -a: outputs matching IP addresses only"
}


db=""
ip=""
port=""
proto=""
addressonly=""
while getopts "f:i:p:P:s:a" OPT; do
	case $OPT in
    f) db="report.txt";;
#		f) db=$OPTARG;;
		i) ip=$OPTARG;;
		p) port=$OPTARG;;
		s) service=$OPTARG;;
		P) proto=$OPTARG;;
		a) addressonly=true;;
		*) usage $0; exit;;
	esac
	echo Running NMAP for ${@: -1}
	sudo nmap -p- -sV -oG report.output ${@: -1} > temp.txt
	rm temp.txt
	grep -v ^# report.output > report.txt
	echo "NMAP result generated to report.txt"
done

if [[ -z $db ]]; then
	# check if nmap-db.grep exists
	if [[ -f ${HOME}/nmap-db.grep ]]; then
		db=${HOME}/nmap-db.grep
	else
		usage $0
		exit
	fi
fi

if [[ ! -z $ip ]]; then # search by IP
	r=$(grep -w "$ip" "$db" | grep -v ^# | sed 's/Ports: /\'$'\n/g' |  tr '/' '\t' | tr ',' '\n' | sed 's/^ //g' | grep -v "Status: Up" | sed 's/Host:/\\033[0;32mHost:\\033[0;39m/g' | sed 's/Ignored State.*$//')
elif [[ ! -z $port ]]; then # search by port number
	r=$(grep -w -E -e "($port)\/open" "$db" | grep -v ^# | sed 's/Ports: /\'$'\n/g' |  tr '/' '\t' | tr ',' '\n' | sed 's/^ //g' | grep -v "Status: Up" | grep -E -e "Host: " -e "^(${port})" | sed 's/Host:/\\033[0;32mHost:\\033[0;39m/g' | sed 's/Ignored State.*$//')
elif [[ ! -z $service ]]; then # search by service name
	r=$(grep -w -E -i -e "($service)" "$db" | grep -v ^# | sed 's/Ports: /\'$'\n/g' |  tr '/' '\t' | tr ',' '\n' | sed 's/^ //g' | grep -v "Status: Up" | grep -i -E -e "Host: " -e "(${service})" | sed 's/Host:/\\033[0;32mHost:\\033[0;39m/g' | sed 's/Ignored State.*$//')
elif [[ ! -z $proto ]]; then
	r=$(grep -w -E -i -e "($proto)" "$db" | grep -v ^# | sed 's/Ports: /\'$'\n/g' |  tr '/' '\t' | tr ',' '\n' | sed 's/^ //g' | grep -v "Status: Up" | grep -i -E -e "Host: " -e "(${proto})" | sed 's/Host:/\\033[0;32mHost:\\033[0;39m/g' | sed 's/Ignored State.*$//')
else
	r=$(cat "$db" | grep -v ^# | sed 's/Ports: /\'$'\n/g' | tr '/' '\t' | tr ',' '\n' | sed 's/^ //g' | grep -v "Status: Up" | sed 's/Host:/\\033[0;32mHost:\\033[0;39m/g' | sed 's/Ignored State.*$//')
fi

if [[ $addressonly ]]; then # output only IPs/hostnames
	echo -e "$r" | grep "Host:" | awk {'print $2'}
else
	echo -e "$r"
fi

service=$(echo "$r" | grep -w -E -i -e "http" | awk {'print $4'})
if [[ $service == *"http"* ]];then
  port=$(echo "$r" | grep -w -E -i -e "http" | awk {'print $1'})
  host=$(echo "$r" | grep "Host:" | awk {'print $2'})
  echo "Running NIKTO for ${@: -1}:$port"
  nikto -port $port -url $host > "$host"_niktoscan.txt
  echo "NIKTO result generated to "$host"_niktoscan.txt"
if [[ $service == *"https"* ]];then
  port=$(echo "$r" | grep -w -E -i -e "http" | awk {'print $1'})
  host=$(echo "$r" | grep "Host:" | awk {'print $2'})
  echo "Running NIKTO for ${@: -1}:$port"
  nikto -port $port -url $host > "$host"_niktoscan.txt
  echo "NIKTO result generated to "$host"_niktoscan.txt"
fi

