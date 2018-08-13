module MarineSky.Container where

import MarineSky.Tracker hiding (new)
import MarineSky.Tracker as T (new)

import Control.Concurrent
import Control.Concurrent.MVar
import Control.Exception (finally)
import qualified Data.Map.Strict as M
import Data.Traversable (traverse)

type Container a = MVar (M.Map Key (Tracker a))

new :: IO (Container a)
new = newMVar M.empty

collect :: Container a -> IO [a]
collect var = do
  ts <- readMVar var
  traverse readContent $ M.elems ts

insert :: Tracker a -> Container a -> IO ()
insert t var = modifyMVarMasked_ var $ \ts ->
  return $ M.insert (show . threadId $ t) t ts

delete :: Key -> Container a -> IO ()
delete k var = modifyMVarMasked_ var $ \ts ->
  return $ M.delete k ts

start :: Container a
      -> MVar a
      -> IO ()
      -> IO ()
start ts var f = finally first after
  where
    first = do
      t <- T.new var
      insert t ts
      f
    after = do
      my <- myThreadId
      delete (show my) ts
