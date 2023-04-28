DISCUZ_DIR=${HOME}/discuz_php_apache_mysql

cd ${DISCUZ_DIR}

echo "Starting website"
docker-compose --env-file ./.env up 

cd -
