{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import MarineSky.Container as Container

import Control.Concurrent
import Control.Concurrent.MVar
import Control.Monad.IO.Class
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
  ts <- Container.new

  scotty 8080 $ do
    get "/" $ do
      vals <- liftIO $ Container.collect ts
      liftIO $ print "get"
      json vals

    post "/" $ do
      var <- liftIO $ newMVar True
      liftIO $ print "post"
      liftIO . forkIO $ Container.start ts var $ do
        threadDelay $ 5 * 1000 * 1000
        swapMVar var False
        threadDelay $ 5 * 1000 * 1000
      return ()
