module Config where

import Data.Maybe
import Safe
import System.Environment

data Config = Config {
  port :: Int,
  dest :: String
} deriving Show

fetch :: IO Config
fetch = do
  p <- lookupEnv "PORT"
  d <- lookupEnv "DEST"
  return $ Config (p >>= readMay ? 8080) (d ? ".")

infixr 0 ?
(?) :: Maybe a -> a -> a
(?) = flip fromMaybe
