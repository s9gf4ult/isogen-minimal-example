{-# OPTIONS -fno-warn-unused-imports #-}
module Main where

import Control.Exception
import Control.Lens
import Data.Default
import Data.Text as T
import System.IO.Unsafe
import Test.HUnit hiding (Node(..))
import Test.Hspec
import TestDefs
import Text.XML.Node


rootExample :: XmlRoot
rootExample = XmlRoot $ XmlFoo "attribute"

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootNodes :: [(Text, Node)]
    rootNodes = render $ writeNodes rootExample
    attrVal :: Maybe Text
    attrVal = rootNodes ^? traversed . named "Foo" . nodeAttributes
      . traversed . named "Quux"
  print rootNodes
  attrVal @?= Just "attribute"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
