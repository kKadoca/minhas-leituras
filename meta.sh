#!/usr/bin/env bash
#
# meta.sh — manda o histórico completo de edições da resenha pro Claude
# e recebe de volta um relato de como foi a leitura.
#
# Uso:  ./meta.sh duna
#       ./meta.sh duna --tela     # imprime em vez de gravar o arquivo
#
# Requer: git e a CLI do Claude Code (`claude`) no PATH.

set -euo pipefail

SLUG="${1:?uso: ./meta.sh <slug> [--tela]}"
MODO="${2:-gravar}"

ARQ="livros/${SLUG}/resenha.txt"
SAIDA="livros/${SLUG}/meta.txt"

[[ -f "$ARQ" ]] || { echo "resenha inexistente: $ARQ" >&2; exit 1; }

# Histórico cronológico do arquivo, em diff de palavra.
#   --reverse            do commit mais antigo pro mais novo
#   --word-diff=plain    mostra [-removido-]{+adicionado+} DENTRO do parágrafo,
#                        em vez de marcar o parágrafo inteiro como trocado
#   --word-diff-regex    trata palavra acentuada como uma palavra só
#   -U0                  sem contexto: só o que mudou, o texto atual já é conhecido
HISTORICO="$(
  git log -p --reverse --follow -U0 --date=short \
      --word-diff=plain \
      --word-diff-regex='[^[:space:]]+' \
      --pretty=format:'%n=== SESSÃO %ad | %s ===' \
      -- "$ARQ"
)"

ATUAL="$(cat "$ARQ")"

read -r -d '' PROMPT <<'EOF' || true
Você vai receber duas coisas: o histórico completo de edições de uma resenha
de livro que escrevi aos poucos, enquanto lia, e a versão final dela.

O histórico está em ordem cronológica. Cada bloco é uma sessão de leitura,
com data e o ponto do livro em que eu estava. Dentro dos parágrafos,
[-assim-] é texto que eu removi e {+assim+} é texto que eu acrescentei ou
coloquei no lugar.

Escreva um relato sobre COMO FOI A MINHA LEITURA. O assunto é a experiência,
não o livro. Não resuma o livro. Não avalie a qualidade da minha escrita.

Fale de:

- Onde eu mudei de ideia. Toda vez que apaguei ou reescrevi um juízo, diga o
  que eu achava antes, em que ponto do livro isso caiu, e o que entrou no
  lugar. Isso é o mais importante do relato.
- Onde o livro me pegou e onde me perdeu. Sessões com muito texto novo
  costumam ser onde engatou; sessões magras, onde arrastou. Aponte o capítulo.
- O que eu levantei cedo e nunca mais toquei, deixando solto.
- O que sobreviveu do primeiro dia até o fim sem eu encostar.

Escreva em português brasileiro, texto corrido em parágrafos, sem títulos,
sem listas, sem markdown. Entre 15 e 25 linhas. Segunda pessoa, direto,
sem elogio automático. Se eu estava errado sobre alguma coisa e o texto
posterior mostra isso, diga com todas as letras. Comece direto no relato,
sem preâmbulo.

=== HISTÓRICO DE EDIÇÕES ===
EOF

CARGA="${PROMPT}"$'\n'"${HISTORICO}"$'\n\n=== VERSÃO FINAL DA RESENHA ===\n'"${ATUAL}"

if [[ "$MODO" == "--tela" ]]; then
  printf '%s\n' "$CARGA" | claude -p
else
  printf '%s\n' "$CARGA" | claude -p > "$SAIDA"
  echo "gravado em $SAIDA"
fi
