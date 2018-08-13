module MarineSky.ProgressSpec where

import MarineSky.Progress

import Control.Concurrent.MVar
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "new" $ do
    it "creates the new progress" $ do
      p <- newMVar $ new "hanamaru"
      readMVar p `shouldReturn` Progress "hanamaru" 0 0

  describe "setCL" $ do
    it "sets the content length" $ do
      p <- newMVar $ new "hanamaru"
      setCL p 1000
      fmap contentLength (readMVar p) `shouldReturn` 1000

    it "overwrites the content length" $ do
      p <- newMVar $ new "hanamaru"
      setCL p 1000
      setCL p 2000
      fmap contentLength (readMVar p) `shouldReturn` 2000

  describe "progress" $ do
    it "accumulates the aquired" $ do
      p <- newMVar $ new "hanamaru"
      fmap aquired (readMVar p) `shouldReturn` 0
      progress p 100
      fmap aquired (readMVar p) `shouldReturn` 100
      progress p 200
      fmap aquired (readMVar p) `shouldReturn` 300
