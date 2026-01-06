#!/usr/bin/env bash
set -euo pipefail

# Script para automatizar o deploy via SSH.
# Uso: ./deploy.sh SEU_HOSTNAME SEU_PORT
# Exemplo: ./deploy.sh example.com 2222

HOST="$1"
PORT="$2"
USER="u804807903"
REMOTE_DIR="domains/homoapp.shop/public_html"
REPO="https://github.com/robertokub/TOP_LIDERES.git"
BRANCH="add/deploy-key-u804807903"

# Auto-bump DATA_VERSION localmente antes do deploy: substitui os arquivos e envia a branch de deploy
TS=$(date +%s)
echo "Auto-bump DATA_VERSION localmente para $TS"
sed -i -E "s/const DATA_VERSION = [0-9]+;/const DATA_VERSION = ${TS};/g" index.html DEMANDAS-TOP.html || true
# Configurar identidade temporária para o commit local
git config user.email "deploy@homoapp.shop" || true
git config user.name "deploy-bot" || true
git add index.html DEMANDAS-TOP.html || true
if git commit -m "Auto-bump DATA_VERSION to ${TS} (deploy)"; then
  # Push para a branch de deploy (atualiza origin/add/deploy-key-u804807903)
  git push origin HEAD:refs/heads/${BRANCH} || true
fi

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  echo "Uso: $0 SEU_HOSTNAME SEU_PORT"
  #!/usr/bin/env bash
  set -euo pipefail

  # Script para automatizar o deploy via SSH usando chave.
  # Uso: ./deploy.sh SEU_HOSTNAME SEU_PORT
  # Exemplo: ./deploy.sh homoapp.shop 65002
  # Requer: variável SSH_KEY_PATH apontando para a chave privada
  # ou ~/.ssh/id_ed25519_homoapp como padrão.

  HOST="${1:-}"
  PORT="${2:-}"
  USER="u804807903"
  REMOTE_DIR="domains/homoapp.shop/public_html"
  REPO_SSH="git@github.com:robertokub/TOP_LIDERES.git"
  BRANCH="add/deploy-key-u804807903"

  SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519_homoapp}"
  SSH_OPTS="-i ${SSH_KEY_PATH} -p ${PORT} -o StrictHostKeyChecking=no"

  if [ -z "$HOST" ] || [ -z "$PORT" ]; then
    echo "Uso: $0 SEU_HOSTNAME SEU_PORT"
    exit 1
  fi

  if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "ERRO: chave SSH não encontrada em: $SSH_KEY_PATH"
    echo "Defina SSH_KEY_PATH ou crie a chave e adicione a pública no SSH Access do hPanel."
    exit 1
  fi

  echo "Conectando em $USER@$HOST:$PORT e preparando deploy em $REMOTE_DIR"

  ssh $SSH_OPTS "$USER@$HOST" "REMOTE_DIR='$REMOTE_DIR' REPO='$REPO' BRANCH='$BRANCH' bash -s" <<'EOF'
  set -euo pipefail

  mkdir -p "$REMOTE_DIR"
  cd "$REMOTE_DIR"

  if [ -z "$(ls -A .)" ]; then
    echo "Diretório vazio — clonando branch $BRANCH"
    git clone -b "$BRANCH" "$REPO" .
  else
    echo "Pasta com conteúdo — conectando ao repositório"
    if [ ! -d .git ]; then
      git init
      git remote remove origin 2>/dev/null || true
      git remote add origin "$REPO"
      git fetch origin
      git checkout -b "$BRANCH" "origin/$BRANCH"
    else
      git remote set-url origin "$REPO" 2>/dev/null || true
      git fetch origin
      if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
        git checkout "$BRANCH"
      else
        git checkout -b "$BRANCH" "origin/$BRANCH"
      fi
    fi

    echo "Atualizando código a partir de origin/$BRANCH"
    git pull origin "$BRANCH"

    # Auto-bump DATA_VERSION para forçar recarga dos dados no cliente
    TS=$(date +%s)
    echo "Atualizando DATA_VERSION para $TS em index.html e DEMANDAS-TOP.html"
    sed -i -E "s/const DATA_VERSION = [0-9]+;/const DATA_VERSION = ${TS};/g" index.html DEMANDAS-TOP.html || true
    git config user.email "deploy@homoapp.shop" || true
    git config user.name "deploy-bot" || true
    git remote set-url origin git@github.com:robertokub/TOP_LIDERES.git || true
    git add index.html DEMANDAS-TOP.html || true
    git commit -m "Auto-bump DATA_VERSION to $TS (deploy)" || true
    git push origin "$BRANCH" || true

  echo "Deploy finalizado em \$(pwd)"
EOF

fi

echo "Conectando em $USER@$HOST:$PORT e preparando deploy em $REMOTE_DIR"

ssh -p "$PORT" "$USER@$HOST" "REMOTE_DIR='$REMOTE_DIR' REPO='$REPO' BRANCH='$BRANCH' bash -s" <<'EOF'
set -euo pipefail
mkdir -p "$REMOTE_DIR"
cd "$REMOTE_DIR"

if [ -z "$(ls -A .)" ]; then
  echo "Diretório vazio — clonando branch $BRANCH"
  git clone -b "$BRANCH" "$REPO" .
else
  echo "Pasta com conteúdo — conectando ao repositório"
  if [ ! -d .git ]; then
    git init
    git remote add origin "$REPO"
    git fetch origin
    git checkout -b "$BRANCH" "origin/$BRANCH"
  else
    git remote set-url origin "$REPO" 2>/dev/null || true
    git fetch origin
    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
      git checkout "$BRANCH"
    else
      git checkout -b "$BRANCH" "origin/$BRANCH"
    fi
    git pull origin "$BRANCH"
  fi
fi
EOF

echo "Deploy concluído (ou sincronização feita)."
