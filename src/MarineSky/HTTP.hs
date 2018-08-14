module MarineSky.HTTP where

import MarineSky.Container as Container
import MarineSky.Env as Env
import MarineSky.File as File
import MarineSky.Progress as Progress
import MarineSky.Renamer as Renamer
import MarineSky.Tracker as Tracker

import Control.Concurrent
import Control.Concurrent.MVar
import Data.ByteString as BS
import Data.ByteString.UTF8 as UTF8
import qualified Data.Map.Strict as Map
import Network.HTTP.Client as Client
import Network.HTTP.Types.Header as Header
import Safe as Safe
import System.IO as IO

download :: Env Progress
         -> Request
         -> (Name, Ext)
         -> IO ()
download env req (n, e) = do
  pg <- newMVar $ Progress.new n
  forkIO $ Container.start (Env.container env) pg $ do
    Client.withResponse req (mngr env) $ \res -> do
      case findCL res of
        Just cl -> Progress.setCL pg cl
        Nothing -> return ()

      File.actBinaryTempFile
        (\handle -> readAll res $ processChunk pg handle)
        (\path -> Renamer.copy path (Env.dest env, n, e))
  return ()

processChunk :: MVar Progress -> Handle -> ByteString -> IO ()
processChunk pg h bs = do
  Progress.progress pg $ BS.length bs
  BS.hPut h bs
  -- readMVar pg >>= print


readAll :: Response BodyReader -> (ByteString -> IO a) -> IO ()
readAll res f = go (Client.responseBody res)
  where
    go r = do
      bs <- Client.brRead r
      f bs
      if BS.null bs then
        return ()
      else
        go r

findCL :: Response a -> Maybe Int
findCL res = do
    bs <- find $ responseHeaders res
    Safe.readMay $ UTF8.toString bs
  where
    find :: ResponseHeaders -> Maybe ByteString
    find = Map.lookup hContentLength . Map.fromList
