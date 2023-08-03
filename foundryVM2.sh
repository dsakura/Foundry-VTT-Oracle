#!/bin/bash
# chmod a+x /home/ubuntu/foundryVM2.sh
# Instalação do Foundry na Oracle e AWS

while true; do
    echo "Escolha uma opção:"
    echo "1 - Instalar o Foundry"
    echo "2 - Configurar S3 da AWS"
    echo "3 - Criar Swapfile"
	echo "4 - Reiniciar o Servidor"
	echo "5 - Sair"

    read -p "Opção: " opcao

    case $opcao in
        1)
            echo "Opção 1 selecionada."
			#Atualiza o Sistema
			sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
			#Atualiza portas abertas
			sudo iptables -I INPUT 6 -m state --state NEW -p tcp --match multiport --dports 80,443,30000 -j ACCEPT
			sudo netfilter-persistent save
			#Adiciona node 18 ao gerenciamento de pacotes do sistema
			curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
			#Adiciona o Caddy ao gerenciamento de pacotes do sistema
			sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
			curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
			curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
			#Instala nodejs, caddy, unzip e nano
			sudo apt update
			sudo apt install nodejs caddy unzip nano -y
			#Instala pm2
			sudo npm install pm2 -g
			sudo npm update -g pm2
			sudo pm2 update
			pm2 startup
			sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
			#Cria pasta do foundry,download, descompacta e remove zip
			mkdir ~/foundry
			echo -e "\\033[0;32mInsira a URL do Foundry na versão NodeJS\\033[0m"
			read tdurl
			wget --output-document ~/foundry/foundryvtt.zip "$tdurl"
			unzip ~/foundry/foundryvtt.zip -d ~/foundry/
			rm ~/foundry/foundryvtt.zip
			#cria pasta Data
			mkdir -p ~/foundryuserdata
			#Configura pm2 para foundry iniciar com o sistema
			pm2 start "node /home/<user>/foundry/resources/app/main.js --dataPath=/home/<user>/foundryuserdata" --name foundry
			pm2 save
			#Configura Caddy Reverse Proxy
			curl -o Caddyfile https://raw.githubusercontent.com/dsakura/Foundry-VTT-Oracle/main/Caddyfile
			sudo rm /etc/caddy/Caddyfile
			sudo mv Caddyfile /etc/caddy/Caddyfile
			echo -e "\\033[0;32mInsira a url do dominio para acessar o foundry vtt\\033[0m"
			read vtturl
			sudo sed -i "s/your.hostname.com/$vtturl/g" /etc/caddy/Caddyfile
			sudo service caddy restart
			#Altera config.json para o reverse proxy
			sed -i 's/"proxyPort": null/"proxyPort": 443/g' /home/ubuntu/foundryuserdata/Config/options.json
			sed -i 's/"proxySSL": false/"proxySSL": true/g' /home/ubuntu/foundryuserdata/Config/options.json
			sed -i 's/"hostname": null/"hostname": "$vtturl"/g' /home/ubuntu/foundryuserdata/Config/options.json
			#Reinicia o Foundry para Completar a Instalacao
			sleep 2
			clear
			pm2 restart foundry
			sleep 3
			;;
		2)
            echo "Opção 2 selecionada."
			curl -o s3.json https://raw.githubusercontent.com/dsakura/Foundry-VTT-Oracle/main/s3.json
			sudo mv s3.json /home/ubuntu/foundryuserdata/Config/s3.json
			echo -e "\\033[0;32mInsira o bucket\\033[0m"
			read bkt
			sed -i 's/"buckets": ["seubucket"]/"buckets": ["$bkt"]/g' /home/ubuntu/foundryuserdata/Config/s3.json
			echo -e "\\033[0;32mInsira o ID\\033[0m"
			read idb
			sed -i 's/"accessKeyId": "suaid"/"accessKeyId": "$idb"/g' /home/ubuntu/foundryuserdata/Config/s3.json
			echo -e "\\033[0;32mInsira a Chave\\033[0m"
			read keyb
			sed -i 's/"secretAccessKey": "suachave"/"secretAccessKey": "$keyb"/g' /home/ubuntu/foundryuserdata/Config/s3.json
			# adiciona o s3 no options
			sed -i 's/"awsConfig": null/"awsConfig": "s3.json"/g' /home/ubuntu/foundryuserdata/Config/options.json
			#Reinicia o Foundry para Completar a Instalacao
			sleep 2
			clear
			pm2 restart foundry
			sleep 3
			;;
		3)
            echo "Opção 3 selecionada."
			#Cria arquivo para ser usado como swap e altera permissao
			sudo fallocate -l 2G /swapfile
			sudo chmod 600 /swapfile
			#Marca o swapfile como uma area de troca do linux
			sudo sed -i -e '$a/swapfile swap swap defaults 0 0' /etc/fstab
			#Ativa o swapfile especificado no fstab
			sudo swapon -a
			sudo swapon --show
			read -p "Pressione Enter para continuar"
			sleep 2
			clear
			sleep 3
			;;
		4)
			echo "Reiniciando o Servidor para completar a Instalação"
			sleep 3
			function selfShred {
				SHREDDING_GRACE_SECONDS=${SHREDDING_GRACE_SECONDS:-5}
				if (( $SHREDDING_GRACE_SECONDS > 0 )); then
					echo -e "Finalizando ${0} in $SHREDDING_GRACE_SECONDS seconds \e[1;31mCTRL-C TO KEEP FILE\e[0m"
					BOMB="●"
					FUZE='~'
					SPARK="\e[1;31m*\e[0m"
					SLEEP_LEFT=$SHREDDING_GRACE_SECONDS
					while (( $SLEEP_LEFT > 0 )); do
						LINE="$BOMB"
						for (( j=0; j < $SLEEP_LEFT - 1; j++ )); do
							LINE+="$FUZE"
						done
						LINE+="$SPARK"
						echo -en $LINE "\r"
						sleep 1
						(( SLEEP_LEFT-- ))
					done
				fi
				shred -u "${0}"
				sudo shutdown -r now
			}

			trap selfShred EXIT
			;;
		5)
			echo "Saindo..."
            sleep 3
			function selfShred {
				SHREDDING_GRACE_SECONDS=${SHREDDING_GRACE_SECONDS:-5}
				if (( $SHREDDING_GRACE_SECONDS > 0 )); then
					echo -e "Finalizando ${0} in $SHREDDING_GRACE_SECONDS seconds \e[1;31mCTRL-C TO KEEP FILE\e[0m"
					BOMB="●"
					FUZE='~'
					SPARK="\e[1;31m*\e[0m"
					SLEEP_LEFT=$SHREDDING_GRACE_SECONDS
					while (( $SLEEP_LEFT > 0 )); do
						LINE="$BOMB"
						for (( j=0; j < $SLEEP_LEFT - 1; j++ )); do
							LINE+="$FUZE"
						done
						LINE+="$SPARK"
						echo -en $LINE "\r"
						sleep 1
						(( SLEEP_LEFT-- ))
					done
				fi
				shred -u "${0}"
			}

			trap selfShred EXIT
			;;
        *)
            echo "Opção inválida."
            ;;
    esac

    read -p "Pressione ENTER para continuar..."
done