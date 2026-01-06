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

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  echo "Uso: $0 SEU_HOSTNAME SEU_PORT"
  exit 1
fi

echo "Conectando em $USER@$HOST:$PORT e preparando deploy em $REMOTE_DIR"

ssh -p "$PORT" "$USER@$HOST" bash -s <<EOF
set -euo pipefail
mkdir -p "$REMOTE_DIR"
cd "$REMOTE_DIR"

if [ -z "
""$(ls -A .)"" ]; then
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
