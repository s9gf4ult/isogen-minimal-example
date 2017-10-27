{-# OPTIONS -fno-warn-unused-imports #-}
module Main where

import Control.Exception
import Data.Default
import Data.Text as T
import ExternalStuff
import System.IO.Unsafe
import Test.HUnit hiding (Node(..))
import Test.Hspec
import TestDefs

rootExample :: XmlRoot
rootExample = XmlRoot XmlFoo

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootNodes :: Maybe Node
    rootNodes = toNode rootExample
    attrVal :: Maybe Text
    attrVal = nodeAttribute <$> rootNodes
  print rootNodes
  attrVal @?= Just "Value from right instance"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
