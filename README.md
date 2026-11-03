# Binômio de Newton — Godot

Base de trabalho organizada a partir dos três scripts e das duas imagens enviados pelo grupo. Projeto para Godot 4.x, com GDScript e renderizador Compatibility.

## Abrir

1. Abra o Godot 4 e escolha **Importar**.
2. Selecione `project.godot` nesta pasta.
3. Pressione **F6** na cena `scenes/fase_01.tscn` ou **F5** para executar o projeto.

## Jogar o protótipo

- A/D ou setas: movimentar.
- Espaço, W ou seta para cima: pular.
- Informe A e B, clique em **Gerar pirâmide** e depois clique fora do painel para posicioná-la.
- A posição clicada corresponde ao topo; as linhas crescem para baixo.
- Alcance a porta na plataforma para concluir. **Reiniciar fase** restaura a cena.
- Para experimentar: A=2, B=3 e topo próximo de (850, 420). A base ficará próxima do chão e os degraus ajudam a alcançar a porta.

## Organização

| Caminho | Conteúdo |
| --- | --- |
| `assets/` | Imagens originais, sem alteração |
| `scripts/player.gd` | Movimento e pulo |
| `scripts/piramide.gd` | Cálculo, desenho e colisões dos blocos |
| `scripts/fase.gd` | Interface e conclusão da fase |
| `scenes/fase_01.tscn` | Cena conectando personagem, pirâmide, porta e chão |
| `docs/PENDENCIAS.md` | Próximos passos para o grupo |

## Ajustes na base recebida

- Separados os três scripts, cada um com seu próprio `extends`.
- Substituída a chamada inexistente `Input.is_key_just_pressed` por tratamento de eventos de teclado sem repetição.
- Movimento suspenso durante a edição dos campos; botão de reinício incluído.
- Cena, colisões e configuração inicial criadas; porta elevada para um desafio inicial provisório.
- Blocos antigos removidos ao gerar novamente; espaçamento corrigido no cálculo de centralização.
- Limite provisório: A e B não negativos, soma de 1 a 12. O limite anterior de 30 pode exceder int64; também produz uma pirâmide maior que a tela. Não há suporte a inteiros arbitrariamente grandes nesta base.

## Matemática e escopo

Cada linha n usa `C(n,k) × A^(n-k) × B^k`, com n começando em zero. A quantidade de linhas continua sendo A+B, conforme o código recebido. Essa quantidade é uma regra do jogo, não uma exigência do teorema binomial. Para expandir uma potência específica `(A+B)^n`, o expoente deve virar um campo independente.

Este é um protótipo inicial: as fases 2 e 3 e seus cenários ainda não foram fornecidos. Os números grandes podem ultrapassar a largura visual das células. Ainda é necessário validar a jogabilidade no editor e ajustar posicionamento, dificuldade e arte.

## Trabalhar em grupo

Cada pessoa deve clonar o repositório, abrir `project.godot` e fazer mudanças em uma branch própria. Versionar `.gd`, `.tscn`, `project.godot`, imagens e arquivos `.uid` gerados pelo Godot. A pasta `.godot/` é cache e fica ignorada.

As imagens foram fornecidas pelo grupo; autoria e licença ainda precisam ser confirmadas. Nenhuma licença de distribuição foi presumida.
