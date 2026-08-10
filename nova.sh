#!/usr/bin/env bash
#
# nova.sh — começa uma resenha
#
# Uso:  ./nova.sh duna "Duna" "Frank Herbert"

set -euo pipefail

SLUG="${1:?uso: ./nova.sh <slug> \"<titulo>\" \"<autor>\"}"
TITULO="${2:-$SLUG}"
AUTOR="${3:-Desconhecido}"
HOJE="$(date +%F)"

DIR="livros/${SLUG}"
[[ -e "$DIR" ]] && { echo "já existe: $DIR" >&2; exit 1; }

mkdir -p "$DIR"
sed -e "s|{{TITULO}}|${TITULO}|g" \
    -e "s|{{AUTOR}}|${AUTOR}|g" \
    -e "s|{{DATA}}|${HOJE}|g" \
    modelos/resenha.txt > "${DIR}/resenha.txt"

git add "${DIR}/resenha.txt"
git commit -q -m "${SLUG}: início — ${TITULO}, ${AUTOR}"

echo "criado ${DIR}/resenha.txt"
