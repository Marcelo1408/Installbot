#!/bin/bash
# INSTALADOR AUTOMÁTICO PARA BOT VPN
# Autor: Marcelo1408

# Cores para melhor visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verificar se é root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}[ERRO] Execute como root ou usando sudo!${NC}"
  exit 1
fi

# Função para instalar Node.js
install_node() {
  echo -e "${YELLOW}[1/5] Instalando Node.js...${NC}"
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
  if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERRO] Falha ao instalar Node.js${NC}"
    exit 1
  fi
}

# Função principal
main() {
  clear
  echo -e "${CYAN}=== INSTALADOR BOT VPN ===${NC}"
  
  # Atualizar sistema
  echo -e "${YELLOW}[1/5] Atualizando pacotes...${NC}"
  sudo apt-get update && sudo apt-get upgrade -y
  
  # Instalar dependências
  install_node
  echo -e "${YELLOW}[2/5] Instalando PM2...${NC}"
  sudo npm install -g pm2
  
  # Baixar e extrair bot
  echo -e "${YELLOW}[3/5] Baixando Bot VPN...${NC}"
  sudo apt-get install -y wget unzip
  wget https://github.com/Marcelo1408/Botvpn/archive/main.zip -O /tmp/bot.zip
  unzip /tmp/bot.zip -d /opt/
  mv /opt/Botvpn-main /opt/botvpn
  rm /tmp/bot.zip
  
  # Instalar dependências do bot
  echo -e "${YELLOW}[4/5] Instalando dependências...${NC}"
  cd /opt/botvpn
  npm install
  
  # Configurar e iniciar
  echo -e "${YELLOW}[5/5] Iniciando serviço...${NC}"
  if [ ! -f ".env" ]; then
    cat > .env <<EOL
TOKEN=seu_token_aqui
PREFIX=!
# Adicione outras variáveis se necessário
EOL
  fi
  
  pm2 start index.js --name "botvpn"
  pm2 startup
  pm2 save
  
  echo -e "${GREEN}\n✔ Instalação concluída com sucesso!${NC}"
  echo -e "\n${CYAN}Comandos úteis:${NC}"
  echo -e "  ${YELLOW}pm2 logs botvpn${NC}     - Ver logs"
  echo -e "  ${YELLOW}pm2 restart botvpn${NC}  - Reiniciar bot"
  echo -e "  ${YELLOW}nano /opt/botvpn/.env${NC} - Editar configurações"
}

main
