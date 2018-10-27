if [ -d "crypto-config" ];then
  sudo rm -rf crypto-config
fi
if [ -d "logs" ];then
  sudo rm -rf logs
fi
mkdir logs
if [ -f "channel.tx" ];then
  sudo rm channel.tx
fi
if [ -f "genesis.block" ];then
  sudo rm genesis.block
fi
docker-compose up -d