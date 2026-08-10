minhas-leituras
===============

Resenhas escritas durante a leitura, não depois. Cada commit é uma sessão, e
os diffs registram a opinião se formando, virando e às vezes se provando
errada. Terminado o livro, um script lê esse histórico e devolve um relato de
como foi a leitura.

Texto puro, parágrafos corridos, sem markdown. Alvo: 6 a 8 parágrafos.

    livros/<slug>/resenha.txt    a resenha, revisada ao longo da leitura
    livros/<slug>/meta.txt       o relato, gerado no fim a partir dos diffs


REGRAS
-----------

1. Revise no lugar. Mudou de ideia, volte no parágrafo errado e reescreva
   ele. Não escreva um parágrafo novo embaixo dizendo "revendo o que falei".
   O par [-removido-]{+acrescentado+} no diff É o registro da virada; sem
   ele o meta.txt não tem do que falar.

2. Enter só no fim do parágrafo, nunca no meio pra segurar a margem. Um
   parágrafo é uma linha só no arquivo. Alt+Z desliga a quebra visual do
   editor: com ela desligada, o parágrafo tem que sair pela direita da tela.


===========================================================================
1. PREPARAR A MÁQUINA
===========================================================================

Uma vez por clone novo:

    chmod +x nova.sh meta.sh
    git config --local include.path ../.gitconfig

O segundo comando ativa os aliases pd, ph e rev. Eles ficam só neste
repositório, não vazam para outros projetos.

Extensões do VS Code:

    code --install-extension streetsidesoftware.code-spell-checker
    code --install-extension streetsidesoftware.code-spell-checker-portuguese-brazilian
    code --install-extension ltex-plus.vscode-ltex-plus


===========================================================================
2. COMEÇAR UM LIVRO
===========================================================================

    ./nova.sh <slug> "<Título>" "<Autor>"

    ./nova.sh donos-do-mercado "Donos do Mercado" "João Peres e Victor Matioli"

Cria livros/<slug>/resenha.txt a partir do modelo e já faz o commit.

Antes de ler qualquer página, escreva o parágrafo de expectativa: o que você
acha do assunto agora. É o parágrafo com mais chance de ser destruído pelo
livro, e é por ele que o meta.txt vai abrir.

    git commit -am "<slug>: antes de começar"


===========================================================================
3. CADA SESSÃO DE LEITURA
===========================================================================

Escreve, revisa, e ao fim da sessão:

    git pd                                   confere o que mudou
    git commit -am "<slug>: cap. 4-6"
    git push

Formato da mensagem:

    <slug>: <onde parei> [marca] — <nota opcional>

    donos-do-mercado: cap. 1-3
    donos-do-mercado: cap. 4-6 [rev] — a concentração é sintoma, não causa
    donos-do-mercado: p. 180-240
    donos-do-mercado: cap. 12-fim [fim]
    outro-livro: cap. 9 [larguei] — se repete

Marcas: [rev] mudei de ideia nesta sessão, [fim] terminei, [larguei]
abandonei, ou nenhuma. Uma por commit. A mensagem é lida pelo modelo depois,
então é contexto, não burocracia.


===========================================================================
4. TERMINAR O LIVRO
===========================================================================

    ./meta.sh <slug>

Grava livros/<slug>/meta.txt. Para ver na tela sem gravar:

    ./meta.sh <slug> --tela

Depois:

    git add -A
    git commit -m "<slug>: meta"
    git push

Requer a CLI do Claude Code (`claude`) no PATH.


===========================================================================
5. CONSULTAR O HISTÓRICO
===========================================================================

    git pd                              o que mudou desde o último commit
    git pd HEAD~3                       desde três sessões atrás
    git ph livros/<slug>/resenha.txt    o histórico inteiro, cronológico
    git rev                             só os commits em que mudei de ideia

    git log --oneline -- livros/<slug>/    todas as sessões de um livro
    grep -rn "duopólio" livros/            procurar um assunto em tudo

O diff normal do git marca o parágrafo inteiro como alterado. Os aliases
acima usam --word-diff, que mostra a mudança palavra a palavra dentro do
parágrafo. Use sempre eles, não o `git diff` puro.


===========================================================================
6. PROBLEMAS COMUNS
===========================================================================

"git: 'pd' is not a git command"
    Faltou o passo 1: git config --local include.path ../.gitconfig

"./nova.sh: Permission denied"
    chmod +x nova.sh meta.sh

O diff marcou o parágrafo inteiro em vermelho e verde
    Você usou `git diff` em vez de `git pd`.

O diff marcou vários parágrafos que eu não toquei
    Tem Enter sobrando no meio de algum parágrafo, ou um formatador reflowou
    o arquivo. Confira com Alt+Z. Nenhum formatador deve rodar em .txt aqui.

O meta.txt saiu genérico
    Poucos commits, ou só acréscimo e nenhuma reescrita. O relato só tem
    material se você tiver revisado parágrafos antigos ao longo da leitura.

`claude: command not found`
    Sem a CLI, rode `./meta.sh <slug> --tela`, copie a saída do comando e
    cole numa conversa. O prompt é o mesmo.
