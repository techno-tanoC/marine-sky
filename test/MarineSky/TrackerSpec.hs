module MarineSky.TrackerSpec where

import MarineSky.Tracker

import Control.Concurrent
import Control.Concurrent.MVar
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "readContet" $ do
    it "reads the content" $ do
      t <- newMVar 0 >>= new
      readContent t `shouldReturn` 0

  describe "readKey" $ do
    it "reads the key" $ do
      t <- newMVar 0 >>= new
      key <- show `fmap` myThreadId
      readKey t `shouldBe` key
