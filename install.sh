#!/bin/bash

# Cores para mensagens
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar erros
check_error() {
  if [ $? -ne 0 ]; then
    echo -e "${RED}[ERRO] $1${NC}"
    exit 1
  fi
}

echo -e "${YELLOW}=== INICIANDO INSTALAÇÃO DO VPS-MANAGER-BOT ===${NC}"

# 1. Atualizar sistema
echo -e "${YELLOW}[1/8] Atualizando pacotes do sistema...${NC}"
sudo apt-get update -y && sudo apt-get upgrade -y
check_error "Falha ao atualizar pacotes"

# 2. Instalar Node.js
echo -e "${YELLOW}[2/8] Instalando Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
check_error "Falha ao instalar Node.js"

# 3. Instalar PM2
echo -e "${YELLOW}[3/8] Instalando PM2...${NC}"
sudo npm install -g pm2
check_error "Falha ao instalar PM2"

# 4. Criar diretório e baixar bot
echo -e "${YELLOW}[4/8] Baixando VPS-Manager-Bot...${NC}"
mkdir -p ~/vps-manager-bot && cd ~/vps-manager-bot
wget https://github.com/Marcelo1408/VPS-Manager-Bot/archive/refs/heads/main.zip -O bot.zip
unzip bot.zip -d . && mv VPS-Manager-Bot-main/* . && rm -rf VPS-Manager-Bot-main bot.zip
check_error "Falha ao baixar e extrair o bot"

# 5. Instalar dependências
echo -e "${YELLOW}[5/8] Instalando dependências...${NC}"
npm install node-telegram-bot-api ssh2 dotenv telegraf axios sqlite3 moment debug node-ssh
check_error "Falha ao instalar dependências"

# 6. Configurar .env
echo -e "${YELLOW}[6/8] Configurando ambiente...${NC}"
if [ ! -f ".env" ]; then
  cat > .env <<EOL
# Configurações do Bot
TOKEN=seu_token_do_telegram_aqui
PREFIX=!

# Configurações SSH
SSH_HOST=seu_host_ssh
SSH_USER=seu_usuario
SSH_PASS=sua_senha
SSH_PORT=22

# Configurações de Log
DEBUG=bot:*
LOG_LEVEL=info
EOL
  echo -e "${YELLOW}Arquivo .env criado. Edite com suas configurações!${NC}"
else
  echo -e "${GREEN}Arquivo .env já existe. Mantendo configurações.${NC}"
fi

# 7. Iniciar o bot
echo -e "${YELLOW}[7/8] Iniciando o bot...${NC}"
pm2 start index.js --name "vps-manager-bot"
check_error "Falha ao iniciar o bot"

# 8. Configurar startup automático
echo -e "${YELLOW}[8/8] Configurando inicialização automática...${NC}"
pm2 startup
pm2 save
check_error "Falha ao configurar startup automático"

echo -e "${GREEN}✔ Instalação concluída com sucesso!${NC}"
echo -e "\n${YELLOW}Comandos úteis:${NC}"
echo -e "  ${GREEN}pm2 logs vps-manager-bot${NC}    - Ver logs"
echo -e "  ${GREEN}pm2 restart vps-manager-bot${NC} - Reiniciar"
echo -e "  ${GREEN}pm2 stop vps-manager-bot${NC}    - Parar"
echo -e "  ${GREEN}pm2 list${NC}                   - Ver todos os processos"
echo -e "\n${YELLOW}IMPORTANTE:${NC}"
echo -e "1. Edite o arquivo ${GREEN}~/.env${NC} com suas configurações reais"
echo -e "2. Se precisar reiniciar o bot após editar o .env:"
echo -e "   ${GREEN}pm2 restart vps-manager-bot${NC}"