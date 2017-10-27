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

instance ToAttribute Foo where
  toAttribute _ = "Value from right instance"

data Root = Root
  { rootFoo :: Foo
  } deriving (Show, Eq)

rootToNode :: Root -> Node
rootToNode (Root foo) = mkNode foo

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootNodes :: Node
    rootNodes = rootToNode $ Root Foo
    attrVal :: Text
    attrVal = nodeAttribute rootNodes
  print rootNodes
  attrVal @?= "Value from right instance"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
