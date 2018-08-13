module MarineSky.RenamerSpec where

import MarineSky.Renamer

import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "freshName" $ do
    context "when the file is not existed" $ do
      it "returns the naive path" $ do
        let check p = return $ p `elem` []
        freshName "/lovelive" "hanamaru" "jpg" check `shouldReturn` "/lovelive/hanamaru.jpg"

      it "returns the fresh path" $ do
        let check p = return $ p `elem` ["/lovelive/hanamaru(1).jpg"]
        freshName "/lovelive" "hanamaru" "jpg" check `shouldReturn` "/lovelive/hanamaru.jpg"

    context "when the file is existed" $ do
      it "returns the doubled path" $ do
        let check p = return $ p `elem` ["/lovelive/hanamaru.jpg"]
        freshName "/lovelive" "hanamaru" "jpg" check `shouldReturn` "/lovelive/hanamaru(1).jpg"

  describe "buildName" $ do
    context "when the file is not existed" $ do
      it "builds the naive name" $ do
        buildName "hanamaru" 0 "jpg" `shouldBe` "hanamaru.jpg"

    context "when the file is existed" $ do
      it "builds the doubled name" $ do
        buildName "hanamaru" 1 "jpg" `shouldBe` "hanamaru(1).jpg"
