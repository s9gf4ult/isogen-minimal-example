{-# OPTIONS -fno-warn-unused-imports #-}
module Main where

import Control.Exception
import Data.Default
import Data.Text as T
import ExternalStuff
import System.IO.Unsafe
import Test.HUnit hiding (Node(..))
import Test.Hspec

data Foo = Foo deriving (Show, Eq)

instance {-# OVERLAPPING#-} ToAttribute Foo where
  toAttribute _ = "Value from right instance"

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootNode = mkNode Foo
  print rootNode
  rootNode @?= "Value from right instance"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
