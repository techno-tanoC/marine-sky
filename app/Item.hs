{-# LANGUAGE DeriveGeneric #-}
module Item where

import MarineSky.Env as Env
import MarineSky.Progress as Progress
import MarineSky.Tracker as Tracker

import Data.Aeson (ToJSON)
import GHC.Generics

data Item = Item {
  name :: String,
  total :: Int,
  size :: Int,
  id :: String
} deriving (Show, Generic)

instance ToJSON Item

fromTracker :: Tracker Progress -> IO Item
fromTracker t = do
  pg <- Tracker.readContent t
  return $ Item (Progress.name pg) (Progress.contentLength pg) (Progress.aquired pg) (Tracker.readKey t)
