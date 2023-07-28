#!/bin/bash    
# chmod a+x /home/ubuntu/atualizarNode.sh
pm2 stop all
pm2 unstartup
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt update
sudo apt upgrade
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
