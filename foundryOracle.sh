#!/bin/bash    
# chmod a+x /home/ubuntu/foundryOracle.sh
# Instalação do Foundry na Oracle e AWS
# atualiza o sistema e remove os pacotes mais antigos
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
#update do iptables para abrir portas 80, 443, 30000
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --match multiport --dports 80,443,30000 -j ACCEPT
# salva esta config
sudo netfilter-persistent save
# instala nodejs, pm2, nano, unzip
sudo apt install curl nano unzip -y
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install pm2 -g
sudo npm update -g pm2
sudo pm2 update
#permite que o pm2 inicie e pare após a reinicialização
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
# cria diretorios necessarios
mkdir ~/foundry
mkdir ~/foundryuserdata
# Instala o caddy para reverse proxy e configuracoes https
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
# Insere o Timed URL do Foundry para download
echo "insira o Timed URL de download do foundry vtt na versão NodeJS"
read tdurl
wget --output-document ~/foundry/foundryvtt.zip "$tdurl"
unzip ~/foundry/foundryvtt.zip -d ~/foundry/
rm ~/foundry/foundryvtt.zip
# Configura o pm2 para iniciar o Foundry vtt na inicialização ou reinicialização do sistema.
pm2 start "node /home/ubuntu/foundry/resources/app/main.js --dataPath=/home/ubuntu/foundryuserdata" --name foundry
pm2 save
# Configurando o proxy reverso do Caddy
curl -o Caddyfile https://raw.githubusercontent.com/aco-rt/Foundry-VTT-Oracle/main/Caddyfile
sudo rm /etc/caddy/Caddyfile
sudo mv Caddyfile /etc/caddy/Caddyfile
echo "Insira o url do domínio do servidor"
read vtturl
sudo sed -i "s/your.hostname.com/$vtturl/g" /etc/caddy/Caddyfile
sudo service caddy restart
# Edita o arquivo foundry options.json para permitir conexões por meio de proxy e 443
sed -i 's/"proxyPort": null/"proxyPort": 443/g' /home/ubuntu/foundryuserdata/Config/options.json
sed -i 's/"proxySSL": false/"proxySSL": true/g' /home/ubuntu/foundryuserdata/Config/options.json
sed -i 's/"hostname": null/"hostname": "$vtturl"/g' /home/ubuntu/foundryuserdata/Config/options.json
# Reinicia o sistema para concluir a instalação
sleep 2
clear
echo "Reiniciando o sistema para concluir a instalação"
sleep 3
sudo shutdown -r now
