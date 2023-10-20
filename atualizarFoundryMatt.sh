#!/bin/bash    
# chmod a+x /home/ubuntu/atualizarFoundry.sh
pm2 stop mfoundry
mv mfoundry mfoundry-archive
mkdir ~/mfoundry
echo "insira o Timed URL de download do foundry vtt na versão NodeJS"
read tdurl
wget --output-document ~/mfoundry/foundryvtt.zip "$tdurl"
unzip ~/mfoundry/foundryvtt.zip -d ~/mfoundry/
rm ~/mfoundry/foundryvtt.zip
pm2 start mfoundry
