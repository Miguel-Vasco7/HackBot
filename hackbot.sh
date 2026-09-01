#!/bin/bash
# hackbot.sh - Enumeração e Validação de Subdomínios (httpx)

TARGET=$1
VT_API_KEY="cd93cf902afc6eca26cfe767ae4b2e9a7bae2b520361f4ae3ffe5cbf09807aa7"

if [ -z "$TARGET" ]; then
    echo "Uso: ./hackbot.sh <dominio-alvo.com>"
    exit 1
fi

OUT_DIR="results_$TARGET"
mkdir -p "$OUT_DIR"

echo "=========================================="
echo "[+] Iniciando Recon de Subdomínios para: $TARGET"
echo "=========================================="

# 1. Coleta Multi-Fonte
echo "[1/2] Coletando subdomínios (Subfinder, Subfaster, crt.sh, VirusTotal)..."

subfinder -d "$TARGET" -silent -o "$OUT_DIR/subfinder.txt"
subfaster -d "$TARGET" -active -oI > "$OUT_DIR/subfaster.txt"
awk '{print $1}' "$OUT_DIR/subfaster.txt" > "$OUT_DIR/subfaster_clean.txt"

curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u > "$OUT_DIR/crtsh.txt"

if [ -n "$VT_API_KEY" ]; then
    curl -s "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$VT_API_KEY&domain=$TARGET" \
    | jq -r '.subdomains[]?' 2>/dev/null | sed "s/$/.$TARGET/" > "$OUT_DIR/virustotal.txt"
else
    touch "$OUT_DIR/virustotal.txt"
fi

# Agrupando todos e gerando all_subdomains.txt
cat "$OUT_DIR/subfinder.txt" "$OUT_DIR/subfaster_clean.txt" "$OUT_DIR/crtsh.txt" "$OUT_DIR/virustotal.txt" | sort -u | grep -v '^$' > "$OUT_DIR/all_subdomains.txt"

# 2. Validação com httpx
echo "[2/2] Validando hosts web ativos com Httpx..."
httpx -l "$OUT_DIR/all_subdomains.txt" -silent -o "$OUT_DIR/live_hosts.txt"

# Limpeza de arquivos temporários da coleta crua
rm -f "$OUT_DIR/subfinder.txt" "$OUT_DIR/subfaster.txt" "$OUT_DIR/subfaster_clean.txt" "$OUT_DIR/crtsh.txt" "$OUT_DIR/virustotal.txt"

echo "=========================================="
echo "[x] Processo concluído com sucesso!"
echo "[+] Total de subdomínios encontrados: $(wc -l < "$OUT_DIR/all_subdomains.txt")"
echo "[+] Total de hosts ATIVOS (HTTP/HTTPS): $(wc -l < "$OUT_DIR/live_hosts.txt")"
echo "[+] Arquivo final de alvos ativos: $OUT_DIR/live_hosts.txt"
echo "=========================================="
