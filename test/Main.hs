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
import Text.XML
import Text.XML.DOM.Parser
import Text.XML.Lens
import Text.XML.Writer

rootExample :: XmlRoot
rootExample = XmlRoot $ XmlFoo "attribute"

isomorphicFoo :: Assertion
isomorphicFoo = do
  let
    rootDoc :: Document
    rootDoc = document "Root" $ toXML rootExample
    attrVal :: Maybe Text
    attrVal = rootDoc ^? root . el "Root" . nodes . traversed . _Element
      . el "Foo" . attr "Quux"
  print rootDoc
  attrVal @?= Just "attribute"

main :: IO ()
main = hspec $ do
  it "has attr" isomorphicFoo
