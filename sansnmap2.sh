#!/bin/bash
curdate=$(date +%Y%m%d)
nmap -n -Pn -iL targets.txt -oA $curdate\_nmap_tcp --reason
nikto -host $curdate\_nmap_tcp.gnmap -ask no -nointeractive -useragent "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1" -Format htm -output $curdate\_nikto.html
