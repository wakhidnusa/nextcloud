#!/bin/bash

NC_DIR=/var/www/nextcloud
CONF_FILE="$NC_DIR/config/config.php"

mkdir -p /var/www/nextcloud

if [ ! -e "$MC_DIR/version.php" ]; then
    cp -r /usr/src/nextcloud /var/www 
    chown -R www-data $NC_DIR
fi

if ! [ -f $CONF_FILE ]
then
    cat <<EOF > $CONF_FILE
<?php 
\$CONFIG = array ( 
EOF

    # Add Redis if config file isn't created
    if [ "$REDIS_ENABLED" != "" ]
    then
        cat <<EOF >> $CONF_FILE
    'memcache.local' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => array(
        'host' => '$REDIS_SERVER',
        'port' => $REDIS_PORT,
        ),
EOF
    fi

    # Add trusted domains
    if [ "$TRUSTED_DOMAINS" != "" ]
    then
        let "count = 0"
        echo "    'trusted_domains' => array (" >> $CONF_FILE
        echo "        0 => 'localhost'," >> $CONF_FILE
        for domain in $(echo $TRUSTED_DOMAINS | sed 's/,/ /g')
        do
            let "count += 1"
            echo "        $count => '$domain'," >> $CONF_FILE
        done
        echo "        )," >> $CONF_FILE    
    fi

    # Set overwrite protocol
    if [ "$OVERWRITEPROTOCOL" != "" ]
    then
        echo "    'overwriteprotocol' => 'https'," >> $CONF_FILE
    fi

    echo ");" >> $CONF_FILE
fi

chown www-data $CONF_FILE

exec "$@"
