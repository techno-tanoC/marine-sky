module MarineSky.Tracker where

import Control.Concurrent
import Control.Concurrent.MVar

data Tracker a = Tracker {
  content :: MVar a,
  threadId :: ThreadId
}

new :: MVar a -> IO (Tracker a)
new var = do
  i <- myThreadId
  return $ Tracker var i

readContent :: Tracker a -> IO a
readContent = readMVar . content

readKey :: Tracker a -> String
readKey = show . threadId

cancel :: Tracker a -> IO ()
cancel = killThread . threadId
