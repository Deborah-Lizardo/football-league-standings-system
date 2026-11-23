module Classificacao
  ( pontos, linhaDoTime, pontosLinha, saldo, aproveitamento
  , classificacao, ateRodada, maiorGoleada, mediaGols
  ) where

import Data.List (foldl', maximumBy, sortBy)
import Data.Ord (Down(..), comparing)
import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate = 1
pontos Derrota = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas t = foldl' acumular inicial (filter (participou t) partidas)
  where
    inicial = Linha t 0 0 0 0 0 0
    -- Reaproveita resultadoPara (Camada 1): a regra de quem venceu fica em um lugar só.
    acumular l p = maybe l (somarJogo l p) (resultadoPara t p)
    somarJogo l p r =
      let (gp, gc) = golsDoPontoDeVista t p
      in l { jogos = jogos l + 1
           , vitorias = vitorias l + contar Vitoria r
           , empates = empates l + contar Empate r
           , derrotas = derrotas l + contar Derrota r
           , golsPro = golsPro l + gp
           , golsContra = golsContra l + gc }
    contar esperado r = if r == esperado then 1 else 0

-- Pontos calculados a partir da funcao pontos, sem repetir os valores 3 e 1.
pontosLinha :: Linha -> Int
pontosLinha l = vitorias l * pontos Vitoria + empates l * pontos Empate

saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise = 100 * fromIntegral (pontosLinha l) / fromIntegral (3 * jogos l)

-- Critérios: pontos, vitórias, saldo, gols pró e nome (ordem alfabética).
classificacao :: [Partida] -> [Linha]
classificacao ps = sortBy criterio (map (linhaDoTime ps) (times ps))
  where
    criterio = comparing (Down . pontosLinha)
           <> comparing (Down . vitorias)
           <> comparing (Down . saldo)
           <> comparing (Down . golsPro)
           <> comparing nomeTime

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n = filter ((<= n) . rodada)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada [] = Nothing
maiorGoleada ps = Just (maximumBy (comparing diferenca) ps)
  where
    diferenca p = abs (golsMandante p - golsVisitante p)

mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols ps = Just (fromIntegral total / fromIntegral (length ps))
  where
    total = sum (map (\p -> golsMandante p + golsVisitante p) ps)
