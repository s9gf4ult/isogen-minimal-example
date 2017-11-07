{-# OPTIONS -fno-warn-unused-imports #-}
module Main where

import ExternalStuff
import Test.Hspec
import Test.HUnit hiding (Node(..))

data Foo = Foo deriving (Show, Eq)

instance {-# OVERLAPPING#-} ToString Foo where
  toString _ = "Foo value - correct instance"

main :: IO ()
main = hspec $ do
  spec "Right instance" $ do
    let t = toString' Foo
    print t
    t @?= "Value from right instance"
