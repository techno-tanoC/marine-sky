{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Config as Config
import Item as Item
import MarineSky as MarineSky

import Control.Monad.IO.Class (liftIO)
import Data.Aeson (FromJSON)
import GHC.Generics
import Web.Scotty
import Network.Wai.Middleware.Cors

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
  conf <- Config.fetch
  env <- MarineSky.new $ Config.dest conf

  scotty (Config.port conf) $ do
    middleware simpleCors

    get "/" $ do
      -- liftIO $ print "get"
      ps <- liftIO $ MarineSky.extract env
      items <- liftIO $ traverse Item.fromTracker ps
      json items

    post "/" $ do
      -- liftIO $ print "push"
      Push n u e <- jsonData
      liftIO $ MarineSky.start env u (n, e)
      return ()

    post "/cancel" $ do
      -- liftIO $ print "cancel"
      Cancel i <- jsonData
      liftIO $ MarineSky.cancel env i
      return ()
