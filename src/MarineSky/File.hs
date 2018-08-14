module MarineSky.File where

import Control.Exception
import System.Directory
import System.IO

actBinaryTempFile :: (Handle -> IO a) -> (FilePath -> IO b) -> IO b
actBinaryTempFile f after = bracket aquire release action
  where
    aquire = openBinaryTempFileWithDefaultPermissions "/tmp" "marine-sky.temp"
    release (path, handle) = do
      ignore $ hClose handle
      ignore $ removeFile path
    action (path, handle) = do
      f handle
      hClose handle
      after path

ignore :: IO () -> IO ()
ignore f = f `catch` ig
  where
    ig :: SomeException -> IO ()
    ig = const $ return ()
