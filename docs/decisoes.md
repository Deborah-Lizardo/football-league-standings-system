# Decisões de modelagem e limitações

- **Tipos algébricos e records:** `Resultado` restringe os resultados a vitória, empate e derrota. `Partida` e `Linha` nomeiam seus campos e reduzem o risco de confusão entre gols pró e contra.
- **Critérios de desempate:** pontos, vitórias, saldo de gols, gols pró e nome em ordem alfabética, nessa prioridade. A ordenação usa `sortBy`, `comparing`, `Down` e composição de comparadores com `<>`.
- **Funções de ordem superior:** `foldl'` (e não `foldr`) acumula a `Linha` de cada time da esquerda para a direita, na ordem das rodadas, e a versão estrita `foldl'` evita acumular contas pendentes. `foldr` foi usado em `separar`, porque ali a lista de pedaços é construída de trás para frente. A `foldl'` os dados de cada time sem recursão explícita; ela reaproveita `resultadoPara` e `pontos` da Camada 1, para que a regra de vitória/empate/derrota e o valor de cada resultado fiquem definidos em um único lugar. `map` constrói linhas, `filter` seleciona partidas e `(.)` compõe consultas.
- **Robustez:** `readMaybe` evita exceções de conversão. `Either Erro` informa o problema e `traverse` para no primeiro erro sintático; `todosOsErros` registra todas as falhas de conversão e duplicações entre partidas válidas.
- **Lista vazia:** `maiorGoleada` e `mediaGols` retornam `Nothing`, e a classificação vazia é `[]`.
- **Armadilhas da Seção 4 e como foram tratadas:**

| Armadilha | Como o projeto evita |
| --- | --- |
| Partida como tupla | `Partida` e `Linha` são records com campos nomeados |
| Resultado como String ou Int | `Resultado` é um tipo soma; com `-Wall`, um caso esquecido gera aviso |
| `head`, `maximum` ou `foldr1` em lista vazia | `maiorGoleada` e `mediaGols` devolvem `Maybe`; `maximumBy` só é chamado com lista não vazia |
| Aproveitamento com `div` | `fromIntegral` converte para `Double` antes da divisão |
| Vários `sortBy` em sequência | um único comparador com `comparing`, `Down` e `<>` |
| Recursão explícita na Camada 2 | só `map`, `filter`, `foldl'`, `sortBy` e composição |
| `read` no placar | `readMaybe`; texto inválido vira `NumeroInvalido` |
| `case` aninhado sobre `Either` | `do` na mônada `Either` em `lerPartida` e `traverse` em `lerCampeonato` |
| `getLine` no `main` | dados como `String` em `Dados.hs`; o `main` é a única função com `IO` |
| Campeonato vazio | lido como `Right []`; tabela vazia e estatísticas `Nothing`, demonstrado no `main` e nos testes |

- **Limitações:** nomes são comparados exatamente após remover espaços nas bordas (maiúsculas e acentos continuam relevantes); resultados não são cruzados com uma tabela oficial; empates em diferença máxima de gols escolhem uma das partidas empatadas; em `todosOsErros`, não são investigadas duplicações envolvendo linhas que já falharam na conversão; não são verificados calendários completos ou um número máximo de jogos por time no campeonato.
