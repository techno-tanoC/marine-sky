{-# LANGUAGE DeriveGeneric #-}
module Item where

import MarineSky.Container as Container
import MarineSky.Tracker as Tracker
import MarineSky.Progress as Progress
import Data.Traversable (traverse)

import Data.Aeson (ToJSON)
import GHC.Generics

data Item = Item {
  name :: String,
  total :: Int,
  size :: Int,
  id :: String
} deriving (Show, Generic)

fromTracker :: Tracker Progress -> IO Item
fromTracker t = do
  pg <- readContent t
  return $ Item (Progress.name pg) (Progress.contentLength pg) (Progress.aquired pg) (Tracker.readKey t)

extract :: Container Progress -> IO [Item]
extract var = do
  ts <- Container.extract var
  traverse fromTracker ts
