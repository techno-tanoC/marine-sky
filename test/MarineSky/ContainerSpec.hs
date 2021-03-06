module MarineSky.ContainerSpec where

import MarineSky.Container

import Control.Concurrent
import Control.Concurrent.MVar
import Control.Exception (finally)
import Data.List (sort)
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "start" $ do
    it "manages contents" $ do
      ts <- new
      var <- newMVar 0
      collect ts `shouldReturn` []
      start ts var $ do
        collect ts `shouldReturn` [0]
      collect ts `shouldReturn` []

    context "with threading" $ do
      it "manages the content" $ do
        ts <- new
        var <- newMVar 0

        one <- newMVar ()
        two <- newMVar ()

        forkIO $ start ts var $ do
          collect ts `shouldReturn` [0]
          takeMVar one
          putMVar two ()

        putMVar one ()
        collect ts `shouldReturn` [0]
        takeMVar two
        takeMVar two

      it "manages contents" $ do
        ts <- new
        var1 <- newMVar 1
        var2 <- newMVar 2

        one <- newMVar ()
        two <- newMVar ()
        three <- newMVar ()
        four <- newMVar ()

        forkIO $ start ts var1 $ do
          takeMVar one
          putMVar two ()

        forkIO $ start ts var2 $ do
          takeMVar three
          putMVar four ()

        putMVar one ()
        putMVar three ()

        cs <- collect ts
        sort cs `shouldBe` [1, 2]

        takeMVar two
        takeMVar two
        takeMVar four
        takeMVar four

  describe "cancel" $ do
    it "cancels the tracking" $ do
      ts <- new
      var <- newMVar (0 :: Int)

      one <- newMVar ()

      i <- forkIO $ finally
        (start ts var $ do
          takeMVar one
          threadDelay $ 10 * 1000 * 1000
        )
        (takeMVar one)

      putMVar one ()
      collect ts `shouldReturn` [0]
      cancel ts $ show i
      putMVar one ()
      collect ts `shouldReturn` []
