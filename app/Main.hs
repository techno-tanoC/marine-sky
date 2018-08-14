{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Item as Item
import MarineSky as MarineSky

import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON)
import GHC.Generics
import Web.Scotty

data Push = Push {
  name :: String,
  url :: String,
  ext :: String
} deriving (Show, Generic)

instance FromJSON Push

data Cancel = Cancel {
  id :: String
} deriving (Show, Generic)

instance FromJSON Cancel

main :: IO ()
main = do
  env <- MarineSky.new "."

  scotty 8080 $ do
    get "/" $ do
      liftIO $ print "get"
      ps <- liftIO $ MarineSky.extract env
      items <- liftIO $ traverse Item.fromTracker ps
      json items

    post "/" $ do
      liftIO $ print "post"
      Push n u e <- jsonData
      liftIO $ MarineSky.start env u (n, e)
      return ()

    post "/cancel" $ do
      liftIO $ print "cancel"
      Cancel i <- jsonData
      liftIO $ MarineSky.cancel env i
      return ()
