module Tipos
  ( Time, Resultado(..), Partida(..), Linha(..)
  , participou, golsDoPontoDeVista, resultadoPara, times
  ) where

import Data.List (nub, sort)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Eq, Show)

data Partida = Partida
  { rodada :: Int
  , mandante :: Time
  , golsMandante :: Int
  , golsVisitante :: Int
  , visitante :: Time
  } deriving (Eq, Show)

data Linha = Linha
  { nomeTime :: Time
  , jogos :: Int
  , vitorias :: Int
  , empates :: Int
  , derrotas :: Int
  , golsPro :: Int
  , golsContra :: Int
  } deriving (Eq, Show)

participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

-- (gols feitos, gols sofridos) do ponto de vista do time; usada pelas Camadas 1 e 2.
golsDoPontoDeVista :: Time -> Partida -> (Int, Int)
golsDoPontoDeVista t p
  | t == mandante p = (golsMandante p, golsVisitante p)
  | otherwise = (golsVisitante p, golsMandante p)

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | not (participou t p) = Nothing
  | feitos > sofridos = Just Vitoria
  | feitos < sofridos = Just Derrota
  | otherwise = Just Empate
  where
    (feitos, sofridos) = golsDoPontoDeVista t p

times :: [Partida] -> [Time]
times = sort . nub . concatMap (\p -> [mandante p, visitante p])
