#!/bin/bash    
# chmod a+x atualizarv10-v11.sh
# Atualiza Foundry v10 para v11
# atualiza o sistema e remove pacotes antigos
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
# para atualizar NodeJS 18, precisa parar os processos pm2
pm2 stop all
# remove pm2 atual da inicialização para permitir o update
pm2 unstartup
# adiciona repo da nova versao NodeJS e atualiza a versão instalada.
sudo apt update
sudo apt upgrade
sudo apt-get install nodejs
sudo apt install npm
# Configura pm2 para versao atualizada do node e inicialização novamente.
npm rebuild -g pm2
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
# reinicia procesos anteriores gerenciados pelo pm2.
pm2 start all
pm2 save
# Updata nodeJS concluido.
# Inicio do update do foundry para v11
# para o foundry
pm2 stop foundry
# cria uma copia de seguranca.
mv foundry foundry-archive-v10
# Baixando e instalando o foundry
mkdir ~/foundry
# Adiciona Foundry timed url para download
echo "Insira foundry vtt v11 timed download url na versão Linux NodeJS"
read tdurl
wget --output-document ~/foundry/foundryvtt.zip "$tdurl"
unzip ~/foundry/foundryvtt.zip -d ~/foundry/
rm ~/foundry/foundryvtt.zip
# Reinicia foundry usando pm2
pm2 start foundry
echo "Reiniciando o sistema para concluir a instalação"
sleep 5
sudo shutdown -r now
