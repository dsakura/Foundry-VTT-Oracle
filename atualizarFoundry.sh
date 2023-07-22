#!/bin/bash    
# chmod a+x /home/ubuntu/atualizarFoundry.sh
pm2 stop foundry
mv foundry foundry-archive
mkdir ~/foundry
echo "insira o Timed URL de download do foundry vtt na versão NodeJS"
read tdurl
wget --output-document ~/foundry/foundryvtt.zip "$tdurl"
unzip ~/foundry/foundryvtt.zip -d ~/foundry/
rm ~/foundry/foundryvtt.zip
pm2 start foundry