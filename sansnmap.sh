#!/bin/bash
ports="80 443"
curdate=$(date +%Y%m%d)
#nmap —n -Pn -iL targets.txt -oA $curdate\_nmap_tcp —-reason
nmap —n -sS -iL targets.txt -oA $curdate\_nmap_tcp —-reason
for testport in $ports
do for targetip in $(awk '/'$testport'\/open/{print $2}' $curdate\_nmap_tcp.gnmap)
do nikto -host $targetip:$testport -ask no —nointeractive
done
done
