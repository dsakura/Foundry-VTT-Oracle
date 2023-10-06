#!/bin/bash    
# chmod a+x /home/ubuntu/atualizarNode.sh
pm2 stop all
pm2 unstartup
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt upgrade
sudo apt install -y nodejs
npm rebuild -g pm2
pm2 startup
pm2 start all
pm2 list
echo "Funcionando? (s ou n)"
read resp
if [ $resp="s" ]
then
	pm2 save
else
	sleep 2
	clear
sleep 2
clear
