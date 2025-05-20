#!/bin/bash
BOT_DIR="/opt/botssh"
REPO_ZIP="https://github.com/Marcelo1408/Botvpn/raw/main/novobotssh.zip"

# Instala Node.js (se não existir)
[ ! -f "/usr/bin/node" ] && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs

# Instala PM2 e dependências
npm install -g pm2
apt install -y wget unzip

# Baixa e extrai o bot
mkdir -p "$BOT_DIR"
wget -q --show-progress "$REPO_ZIP" -O /tmp/bot.zip
unzip /tmp/bot.zip -d /tmp/
mv /tmp/novobotssh/* "$BOT_DIR"
rm -rf /tmp/bot.zip /tmp/novobotssh

# Instala dependências do bot
cd "$BOT_DIR"
npm install --save node-telegram-bot-api ssh2 dotenv telegraf axios sqlite3 moment debug node-ssh

# Cria .env padrão
cat > .env <<EOL
TOKEN=seu_token_aqui
PREFIX=!
SSH_HOST=seu_servidor
SSH_PORT=22
SSH_USER=usuario
SSH_PASSWORD=senha
EOL

# Inicia com PM2
pm2 start index.js --name "botssh"
pm2 save
pm2 startup

echo -e "\n✅ Bot instalado em $BOT_DIR"
echo -e "⚠ Edite o .env: nano $BOT_DIR/.env"
echo -e "🔄 Reinicie após editar: pm2 restart botssh"
