{-# OPTIONS -fno-warn-unused-imports #-}
module Main where

import ExternalStuff
import Test.Hspec
import Test.HUnit hiding (Node(..))

toString' :: (ToString a) => a -> String
toString' = toString

data Foo = Foo deriving (Show, Eq)

instance {-# OVERLAPPING#-} ToString Foo where
  toString _ = "Value from right instance"

main :: IO ()
main = hspec $ do
  it "Right instance" $ do
    let t = toString' Foo
    print t
    t @?= "Value from right instance"
