module MarineSky (
  Env.new,
  collect,
  start,
  cancel
) where

import qualified MarineSky.Container as Container
import MarineSky.Env as Env
import qualified MarineSky.Tracker as Tracker

collect :: Env a -> IO [a]
collect = Container.collect . Env.container

cancel :: Env a -> String -> IO ()
cancel = Container.cancel . Env.container

start :: Env a -> String -> IO ()
start env req = undefined
