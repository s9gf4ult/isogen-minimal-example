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

instance ToNode Foo where
  toNode _ = Nothing

instance ToAttribute Foo where
  toAttribute _ = "Value from right instance"

data Root = Root
  { _xrFoo :: Foo
  } deriving (Show, Eq)

instance ToNode Root where
  toNode r = Just $ (\a -> Node (toNode a) (toAttribute a)) (_xrFoo r)

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootNodes :: Maybe Node
    rootNodes = toNode $ Root Foo
    attrVal :: Maybe Text
    attrVal = nodeAttribute <$> rootNodes
  print rootNodes
  attrVal @?= Just "Value from right instance"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
