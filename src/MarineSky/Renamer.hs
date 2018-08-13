module MarineSky.Renamer where

import Control.Concurrent.MVar
import Control.Exception (finally)
import System.Directory (copyFile, doesPathExist)
import System.FilePath ((</>))
import System.IO.Unsafe (unsafePerformIO)
import System.Posix (setOwnerAndGroup)

type Sem = MVar ()

{-# NOINLINE sem #-}
sem :: Sem
sem = unsafePerformIO $ newMVar ()

sync :: IO a -> IO a
sync f = finally (takeMVar sem >> f) (putMVar sem ())

type Path = String
type Name = String
type Ext = String

copy :: Path -> (Path, Name, Ext) -> IO ()
copy from (p, n, e) = sync $ do
  fresh <- freshName p n e doesPathExist
  copyFile from fresh
  setOwnerAndGroup fresh (fromInteger 1000) (fromInteger 1000)

freshName :: Path -> Name -> Ext -> (Path -> IO Bool) -> IO Path
freshName p n e check = go 0
  where
    fullPath i = p </> buildName n i e
    go i = do
      b <- check $ fullPath i
      if b then
        go (i + 1)
      else
        return $ fullPath i

buildName :: Name -> Int -> Ext -> String
buildName n i e = n ++ count i ++ tail e
  where
    count :: Int -> String
    count x | x <= 0 = ""
            | otherwise = "(" ++ show x ++ ")"
    tail :: String -> String
    tail "" = ""
    tail ext = '.' : ext
