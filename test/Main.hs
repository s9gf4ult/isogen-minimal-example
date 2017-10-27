{-# OPTIONS -fno-warn-unused-imports #-}
module Main where

import Control.Exception
import Control.Lens
import Data.Default
import Data.Text as T
import ExternalStuff
import System.IO.Unsafe
import Test.HUnit hiding (Node(..))
import Test.Hspec
import TestDefs


named :: Text -> Traversal' (Text, a) a
named expected = filtered expName . _2
  where
    expName (name, _) = name == expected

rootExample :: XmlRoot
rootExample = XmlRoot XmlFoo

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootNodes :: Maybe Node
    rootNodes = toNode rootExample
    attrVal :: Maybe Text
    attrVal = rootNodes ^? _Just . nodeAttribute
  print rootNodes
  attrVal @?= Just "Value from right instance"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
