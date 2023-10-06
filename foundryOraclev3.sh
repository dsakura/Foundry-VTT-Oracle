#!/bin/bash    
# chmod a+x /where/i/saved/it/foundryInstall.sh
# Instalação do Foundry na Oracle
# Atualiza o sistema e remove pacotes antigos
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
# Atualiza o iptables para abrir as portas 80, 443, 30000
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --match multiport --dports 80,443,30000 -j ACCEPT
# Salva as configs
sudo netfilter-persistent save
# Instala nodejs, pm2, nano, unzip
sudo apt install curl nano unzip -y
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs
sudo npm install pm2 -g
sudo npm update -g pm2
sudo pm2 update
#permite pm2 iniciar e parar apos reiniciar
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
# cria as pastas necessarias
mkdir ~/foundry
mkdir ~/foundryuserdata
# Instala caddy para configurar reverse proxy e https
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
# Adiciona url de instalacao
echo "Insira Foundry VTT Timed Download URL na versão NodeJS"
read tdurl
wget --output-document ~/foundry/foundryvtt.zip "$tdurl"
unzip ~/foundry/foundryvtt.zip -d ~/foundry/
rm ~/foundry/foundryvtt.zip
# Configura pm2 para iniciar foundry vtt qdo sistema iniciar ou reiniciar.
pm2 start "node /home/ubuntu/foundry/resources/app/main.js --dataPath=/home/ubuntu/foundryuserdata" --name foundry
pm2 save
# Configura Caddy reverse proxy
curl -o Caddyfile https://raw.githubusercontent.com/aco-rt/Foundry-VTT-Oracle/main/Caddyfile
sudo rm /etc/caddy/Caddyfile
sudo mv Caddyfile /etc/caddy/Caddyfile
echo "Insira URL do dominio para se conectar ao servidor"
read vtturl
sudo sed -i "s/your.hostname.com/$vtturl/g" /etc/caddy/Caddyfile
sudo service caddy restart
# Edita arquivo foundry options.json para permitir conexoes pelo proxy e porta 443
sed -i 's/"proxyPort": null/"proxyPort": 443/g' /home/ubuntu/foundryuserdata/Config/options.json
sed -i 's/"proxySSL": false/"proxySSL": true/g' /home/ubuntu/foundryuserdata/Config/options.json
sed -i 's/"hostname": null/"hostname": "$vtturl"/g' /home/ubuntu/foundryuserdata/Config/options.json
# Reinicia sistema para completar a instalacao
sleep 2
clear
echo "Reiniciando o sistema para completar a instalação"
sleep 3
(sh -c "sleep 1; rm -- '\$0'" &)
sudo shutdown -r now