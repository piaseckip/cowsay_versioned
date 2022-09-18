adress=$(ip address | grep -E 172.17.0.[2-] | cut -d "/" -f 1 | cut -c 10- )
echo "Cowsey is set on $adress:$PORT"
node index.js

