#!/bin/bash
# hackbot.sh - Pipeline Completo de Recon, JS Extraction & Vulnerability Scanning

TARGET=$1
VT_API_KEY="cd93cf902afc6eca26cfe767ae4b2e9a7bae2b520361f4ae3ffe5cbf09807aa7"

if [ -z "$TARGET" ]; then
    echo "Uso: ./hackbot.sh <dominio-alvo.com>"
    exit 1
fi

OUT_DIR="results_$TARGET"
mkdir -p "$OUT_DIR/js_files"

echo "=========================================="
echo "[+] Iniciando HackBot Completo para: $TARGET"
echo "=========================================="

# -------------------------------------------------------------------
# CAMADA 1: SUBDOMÍNIOS, RESOLUÇÃO & COLETA DE URLS
# -------------------------------------------------------------------
echo "[1/4] Coletando subdomínios (Subfinder, Subfaster, crt.sh, VirusTotal)..."

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

cat "$OUT_DIR/subfinder.txt" "$OUT_DIR/subfaster_clean.txt" "$OUT_DIR/crtsh.txt" "$OUT_DIR/virustotal.txt" | sort -u | grep -v '^$' > "$OUT_DIR/all_subdomains.txt"

echo "[+] Validando hosts web ativos com Httpx..."
httpx -l "$OUT_DIR/all_subdomains.txt" -silent -o "$OUT_DIR/live_hosts.txt"

echo "[+] Coletando histórico de URLs (Waybackurls & GAU)..."
cat "$OUT_DIR/live_hosts.txt" | waybackurls > "$OUT_DIR/urls_wayback.txt"
gau "$TARGET" --subs >> "$OUT_DIR/urls_wayback.txt"
cat "$OUT_DIR/urls_wayback.txt" | sort -u > "$OUT_DIR/all_urls.txt"
echo "[+] Total de URLs/Endpoints mapeados: $(wc -l < $OUT_DIR/all_urls.txt)"

# -------------------------------------------------------------------
# CAMADA 2: EXTRAÇÃO DE JAVASCRIPT & ANÁLISE DE SEGREDOS (KEYS/TOKENS)
# -------------------------------------------------------------------
echo "[2/4] Filtrando e analisando arquivos JavaScript..."

# Filtrar URLs que terminam com .js
grep -iE '\.js(\?.*)?$' "$OUT_DIR/all_urls.txt" | sort -u > "$OUT_DIR/js_urls.txt"
echo "[+] Encontrados $(wc -l < $OUT_DIR/js_urls.txt) arquivos JS."

# Busca de chaves/segredos sensíveis via Regex nos arquivos JS
echo "[+] Buscando segredos (API Keys, Tokens, AWS, Firebase, Stripe)..."
REGEX_SECRETS='(aws_access_key_id|aws_secret_access_key|api[_-]?key|secret[_-]?key|access[_-]?token|bearer[_-]?token|firebase|stripe[_-]?pk|stripe[_-]?sk|twilio_account_sid|google_api_key|github_token)[[:space:]]*[:=][[:space:]]*["'\''][A-Za-z0-9_/-]{8,}["'\'']'

> "$OUT_DIR/extracted_secrets.txt"
while read -r js_url; do
    [ -z "$js_url" ] && continue
    curl -s -L --max-time 5 "$js_url" | grep -iE "$REGEX_SECRETS" >> "$OUT_DIR/extracted_secrets.txt"
done < "$OUT_DIR/js_urls.txt"

sort -u "$OUT_DIR/extracted_secrets.txt" -o "$OUT_DIR/extracted_secrets.txt"
echo "[+] Segredos/Keys filtrados salvos em: $OUT_DIR/extracted_secrets.txt"

# Coletar novas rotas escondidas nos arquivos JS (Endpoints)
echo "[+] Extraindo novas rotas de dentro dos arquivos JS..."
grep -oE '("|\')/[a-zA-Z0-9_?&=/.-]+("|\')' "$OUT_DIR/js_urls.txt" | tr -d '"' | tr -d "'" | sort -u > "$OUT_DIR/js_endpoints.txt"

# -------------------------------------------------------------------
# CAMADA 3: DISPARO DE SCANNERS (NUCLEI, DALFOX, XSSTRIKE)
# -------------------------------------------------------------------
echo "[3/4] Executando Nuclei contra hosts e URLs..."
nuclei -l "$OUT_DIR/all_urls.txt" -severity low,medium,high,critical -o "$OUT_DIR/nuclei_results.txt"

echo "[4/4] Executando Dalfox para varredura automatizada de XSS..."
cat "$OUT_DIR/all_urls.txt" | grep '=' | dalfox pipe --silence -o "$OUT_DIR/dalfox_xss.txt"

echo "[+] Testando URLs vulneráveis com XSStrike (Apenas URLs com parâmetros)..."
grep '=' "$OUT_DIR/all_urls.txt" | head -n 30 > "$OUT_DIR/xss_targets.txt"
while read -r url; do
    [ -z "$url" ] && continue
    python3 $HOME/XSStrike/xsstrike.py -u "$url" --crawl --skip-dom >> "$OUT_DIR/xsstrike_results.txt" 2>&1
done < "$OUT_DIR/xss_targets.txt"

echo "=========================================="
echo "[x] Processo concluído com sucesso!"
echo "[x] Relatórios gerados no diretório: $OUT_DIR"
echo "=========================================="
