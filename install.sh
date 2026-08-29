#!/bin/bash
# install.sh - Instalação de ferramentas de Recon, JS Analysis & Scanners

set -e

echo "[+] Atualizando o sistema e instalando dependências básicas..."
sudo apt update && sudo apt install -y curl wget git nmap python3 python3-pip golang-go jq

# Configurar ambiente Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
if ! grep -q "GOPATH" ~/.bashrc; then
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
fi

echo "[+] Instalando Subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "[+] Instalando Subfaster..."
go install -v github.com/melvinsh/subfaster@latest

echo "[+] Instalando Httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo "[+] Instalando Nuclei..."
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

echo "[+] Instalando Dalfox (XSS Scanner)..."
go install -v github.com/hahwul/dalfox/v2@latest

echo "[+] Instalando Waybackurls & GAU (Coleta de URLs)..."
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest

echo "[+] Instalando ferramentas de extração de JS e Segredos..."
pip3 install JSFinder SecretFinder --break-system-packages 2>/dev/null || pip3 install JSFinder SecretFinder

echo "[+] Clonando XSStrike..."
if [ ! -d "$HOME/XSStrike" ]; then
    git clone https://github.com/s0md3v/XSStrike.git $HOME/XSStrike
    pip3 install -r $HOME/XSStrike/requirements.txt --break-system-packages 2>/dev/null || pip3 install -r $HOME/XSStrike/requirements.txt
fi

echo "[+] Atualizando templates do Nuclei..."
$GOPATH/bin/nuclei -update-templates

echo "[x] Instalação concluída! Execute: source ~/.bashrc"
