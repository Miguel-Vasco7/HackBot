<p align="center">
  <img src="hackbot.jpg" alt="HackBot Demo" width="600">
</p>



# 🤖 HackBot — Advanced Recon & JS Extraction Engine

**HackBot** é um framework poderoso em Shell Script projetado para automatizar e acelerar a fase mais importante do Bug Bounty e Pentest: **o Reconhecimento e Mapeamento de Ativos.**

Desenvolvido para hunters que focam em validação manual de alto impacto, o HackBot elimina o trabalho repetitivo de terminal, unificando a coleta de múltiplos provedores, filtragem de hosts ativos e extração profunda de arquivos JavaScript em um único pipeline contínuo.


### ⚡ O que faz do HackBot tão poderoso?

* **Recon Multi-Fonte (Subdomain Enumeration):** Agrega e remove duplicatas de subdomínios consultando ferramentas passivas e ativas (`Subfinder`, `Subfaster`, `crt.sh` e API do `VirusTotal`) em segundos.
* **Validação de Hosts Ativos:** Integração direta com o `httpx` para filtrar instantaneamente apenas os domínios que estão respondendo via HTTP/HTTPS, eliminando falsos alvos.
* **Mapeamento de Histórico (URL Mining):** Mineração massiva de URLs e endpoints antigos usando `waybackurls` e `gau` com suporte completo a subdomínios (*wildcards*).
* **JavaScript Mining & Secrets Extraction:** Filtra automaticamente todos os arquivos `.js` do alvo e executa uma varredura via Expressões Regulares (Regex) para identificar vazamentos de **API Keys, Tokens OAuth, AWS Credentials, Firebase e rotas/endpoints ocultos**.
* **Pronto para Validação Manual:** Organiza todos os resultados em diretórios limpos e arquivos estruturados, prontos para serem carregados direto no **Burp Suite** para testes de lógicas de negócio e Broken Access Control (BAC).
## 📋 Pré-requisitos

Liste os pacotes ou dependências necessários para execução:

- Ubuntu / Debian Linux
- Git
- Curl / Wget

## 🛠️ Instalação

Instruções diretas sobre como clonar o repositório e configurar as permissões:

### ⚙️ Permissões e Instalação

Conceda permissão de execução aos scripts e instale as dependências do sistema:

```bash
# Conceder permissão de execução
chmod +x install.sh hackbot.sh

# Executar a instalação das ferramentas
./install.sh

# Executar o script no alvo desejado
./hackbot.sh alvo.com


```

## 📜 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.
