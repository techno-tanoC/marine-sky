module MarineSky (
  Env.new,
  extract,
  start,
  cancel
) where

import qualified MarineSky.Container as Container
import MarineSky.Env as Env
import MarineSky.HTTP as HTTP
import MarineSky.Progress as Progress
import MarineSky.Renamer (Name, Ext)
import qualified MarineSky.Tracker as Tracker

import Network.HTTP.Client (Request, parseRequest_)

extract :: Env a -> IO [Tracker.Tracker a]
extract = Container.extract . Env.container

cancel :: Env a -> String -> IO ()
cancel = Container.cancel . Env.container

start :: Env Progress -> String -> (Name, Ext) -> IO ()
start env req n = HTTP.download env (parseRequest_ req) n
