module MarineSky.Container where

import MarineSky.Tracker as Tracker

import Control.Concurrent
import Control.Concurrent.MVar
import Control.Exception (finally)
import qualified Data.Map.Strict as Map
import Data.Traversable (traverse)

type Key = String
type Container a = MVar (Map.Map Key (Tracker a))

new :: IO (Container a)
new = newMVar Map.empty

collect :: Container a -> IO [a]
collect var = do
  ts <- readMVar var
  traverse readContent $ Map.elems ts

insert :: Tracker a -> Container a -> IO ()
insert t var = modifyMVarMasked_ var $ \ts ->
  return $ Map.insert (show . threadId $ t) t ts

delete :: Key -> Container a -> IO ()
delete k var = modifyMVarMasked_ var $ \ts ->
  return $ Map.delete k ts

start :: Container a
      -> MVar a
      -> IO ()
      -> IO ()
start ts var f = finally first after
  where
    first = do
      t <- Tracker.new var
      insert t ts
      f
    after = do
      my <- myThreadId
      delete (show my) ts

cancel :: Container a -> Key -> IO ()
cancel var key = do
  ts <- readMVar var
  case Map.lookup key ts of
    Just t -> Tracker.cancel t
    Nothing -> return ()
