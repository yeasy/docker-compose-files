DISCUZ_DIR=${HOME}/discuz_php_apache_mysql

cd ${DISCUZ_DIR}

echo "Stopping website"
docker-compose --env-file ./.env down

cd -
