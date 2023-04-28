DISCUZ_DIR=${HOME}/discuz_php_apache_mysql

cd ${DISCUZ_DIR}

echo "Stopping website"
docker-compose --env-file ./.env down

sleep 2

echo "Backuping data"
sudo tar -czf /${HOME}/discuz_$(date +%Y%m%d).tar.gz ${DISCUZ_DIR}

echo "Starting website"
docker-compose --env-file ./.env up 

cd -
