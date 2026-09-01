#!/bin/bash
# install.sh - Instalação de dependências para o HackBot

echo "=========================================="
echo "[+] Instalando dependências do HackBot..."
echo "=========================================="

# 1. Atualiza repositórios e instala dependências básicas de sistema
sudo apt update && sudo apt install -y curl jq git golang-go

# 2. Configura ambiente Go (se ainda não estiver configurado)
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
mkdir -p "$GOPATH/bin"

# Garante que o Go path fique permanente no ~/.bashrc
if ! grep -q "GOPATH" "$HOME/.bashrc"; then
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
fi

# 3. Instala Subfinder (ProjectDiscovery)
echo "[+] Instalando Subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# 4. Instala Httpx (ProjectDiscovery)
echo "[+] Instalando Httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# 5. Instala Subfaster
echo "[+] Instalando Subfaster..."
go install -v github.com/drsploit/subfaster@latest

# 6. Torna o script principal executável
if [ -f "hackbot.sh" ]; then
    chmod +x hackbot.sh
fi

echo "=========================================="
echo "[x] Instalação concluída!"
echo "[!] Dica: Execute 'source ~/.bashrc' se os comandos 'subfinder' ou 'httpx' não forem encontrados."
echo "=========================================="
