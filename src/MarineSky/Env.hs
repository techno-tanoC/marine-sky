module MarineSky.Env where

import qualified MarineSky.Container as Container (new)
import MarineSky.Container (Container)

import Network.HTTP.Client (Manager)
import Network.HTTP.Client.TLS (newTlsManager)

data Env a = Env {
  dest :: String,
  mngr :: Manager,
  container :: Container a
}

new :: String -> IO (Env a)
new d = do
  m <- newTlsManager
  c <- Container.new
  return $ Env d m c
