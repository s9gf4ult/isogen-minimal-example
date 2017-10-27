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

instance {-# OVERLAPPING#-} ToText Foo where
  toText _ = "Value from right instance"

main :: IO ()
main = hspec $ do
  it "Right instance" $ do
    let t = toTextProxy Foo
    print t
    t @?= "Value from right instance"
