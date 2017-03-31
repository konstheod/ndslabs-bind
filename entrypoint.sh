#!/bin/bash
set -e

#sed "s/{{\s*EMAIL_ADDRESS\s*}}/$EMAIL_ADDRESS/g" -i /var/lib/bind/ndslabs.org.hosts 
#sed "s/{{\s*IP_ADDRESS\s*}}/$IP_ADDRESS/g" -i /var/lib/bind/ndslabs.org.hosts 


BASE_DOMAIN=`echo $DOMAIN | cut -d. -f2,3`

cat << EOF > /etc/bind/named.conf.local
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "$BASE_DOMAIN" {
    type master;
    file "/var/lib/bind/$BASE_DOMAIN.hosts";
    };
EOF

cat << EOF > /var/lib/bind/$BASE_DOMAIN.hosts
\$ttl 38400
$BASE_DOMAIN.    IN      SOA     ns.$BASE_DOMAIN. $EMAIL_ADDRESS. (
                        1490971991
                        10800
                        3600
                        604800
                        38400 )
$BASE_DOMAIN.    IN      NS      ns.$BASE_DOMAIN.
*.$DOMAIN.    IN      A       $IP_ADDRESS
ns.$BASE_DOMAIN. IN      A       $IP_ADDRESS
EOF

if [ "$1" = 'named' ]; then
  echo "Starting named..."
  exec $(which named) -g
else
  exec "$@"
fi
