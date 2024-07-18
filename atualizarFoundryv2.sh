#!/bin/bash 
# chmod a+x atualizarFoundryv2.sh

# Exibir instruções de uso se nenhum argumento for fornecido
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 {option1|option2|option3}"
    exit 1
fi

# Processa cada opção
case $1 in
    option1)
        echo "Atualizar Apenas Foundry"
        # atualiza o sistema e remove pacotes antigos
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
        # para atualizar NodeJS 18, precisa parar os processos pm2
        pm2 stop all
        # remove pm2 atual da inicialização para permitir o update
        pm2 unstartup
        # Inicio do update do foundry
        pm2 stop foundry
        # Define o nome do diretório base
        base_dir="backup-foundry"

        # Obtém a data atual no formato DDMMYY
        date=$(date +%d%m%y)

        # Anexa a data ao nome do diretório
        dir="$base_dir-$date"

        # Se o diretório já existe, cria uma cópia numerada
        if [ -d "$dir" ]; then
          i=1
          while [ -d "$dir-$i" ] ; do
            let i++
          done
          dir="$dir-$i"
        fi

        # Use o comando mv para renomear o diretório
        mv $base_dir $dir

        echo "Directory has been renamed to: $dir"
        sleep 5
        # Baixando e instalando o foundry
        rm -rf ~/foundry
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
        ;;
    option2)
        echo "Atualizar Foundry mais Node"
        echo "Atualizar Apenas Foundry"
        # atualiza o sistema e remove pacotes antigos
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
        # para atualizar NodeJS 18, precisa parar os processos pm2
        pm2 stop all
        # remove pm2 atual da inicialização para permitir o update
        pm2 unstartup
        #atualiza repo do node e o atualiza
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt update && sudo apt upgrade
        # atualiza npm
        sudo npm install -g npm@latest
        # Configura pm2 para versao atualizada do node e inicialização novamente.
        npm rebuild -g pm2
        pm2 startup
        sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
        # reinicia procesos anteriores gerenciados pelo pm2.
        pm2 start all
        pm2 save
        # Updata nodeJS concluido.
        # Inicio do update do foundry
        pm2 stop foundry
                # Define o nome do diretório base
        base_dir="backup-foundry"

        # Obtém a data atual no formato DDMMYY
        date=$(date +%d%m%y)

        # Anexa a data ao nome do diretório
        dir="$base_dir-$date"

        # Se o diretório já existe, cria uma cópia numerada
        if [ -d "$dir" ]; then
          i=1
          while [ -d "$dir-$i" ] ; do
            let i++
          done
          dir="$dir-$i"
        fi

        # Use o comando mv para renomear o diretório
        mv $base_dir $dir

        echo "Directory has been renamed to: $dir"
        sleep 5
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
        ;;
    option3)
        echo "Apagar Data"
        pm2 stop foundry
        # Defina os caminhos para as pastas
        dir1="/home/ubuntu/foundryuserdata/Data"
        dir2="/home/ubuntu/.local/share/FoundryVTT/Data"

        # Tenta remover a primeira pasta
        if [ -d "$dir1" ]; then
            echo "Removendo $dir1"
            rm -rf "$dir1"
            mkdir "$dir1"
        else
            echo "Pasta $dir1 não encontrada, tentando a segunda opção"

            # Tenta remover a segunda pasta
            if [ -d "$dir2" ]; then
                echo "Removendo $dir2"
                rm -rf "$dir2"
                mkdir "$dir2"
            else
                echo "Pasta $dir2 não encontrada"
            fi
        fi
        ;;
    *)
        echo "Invalid option: $1"
        echo "Usage: $0 {option1|option2|option3}"
        exit 1
esac

exit 0
