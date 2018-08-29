#!/bin/bash

export siteName="$1"

if [ -z "$siteName" ]; then
	echo "siteName is not set - exiting.."	
	exit; 
fi

if [ ! $(whoami) == "root" ]; then 
	sudo $0; 
	exit
fi
echo "* sleeping for 3 sec.."
sleep 3

# Renewing the certificate in common folder
sudo certbot renew --http-01-port 9080 --tls-sni-01-port 9443

# Renewing the cerficiate for Jira & confluence
cd /etc/letsencrypt/live/$siteName/
openssl pkcs12 -export -out bundle.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem -password pass:MyHomeIsHere
cp /opt/atlassian/bundle.pfx /opt/atlassian/bundle.pfx.$(date +%Y-%m-%d)
cp /etc/letsencrypt/live/$siteName/bundle.pfx /opt/atlassian/
chmod g+r /opt/atlassian/bundle.pfx

echo "* sleeping for 3 sec.."
sleep 3
/etc/init.d/confluence restart
/etc/init.d/jira stop
/etc/init.d/jira start
