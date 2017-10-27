{-# OPTIONS -ddump-splices #-}

module TestDefs where

import Data.Text as T
import ExternalStuff
import GHC.Generics (Generic)

data XmlFoo = XmlFoo deriving (Generic, Show, Eq)

instance WriteNodes XmlFoo where
  writeNodes _ = []

instance ToAttribute XmlFoo where
  toAttribute _ = "Value from right instance"

data XmlRoot = XmlRoot
  { _xrFoo :: XmlFoo
  } deriving (Generic, Show, Eq)

instance WriteNodes XmlRoot where
  writeNodes r = id (mkElement "Foo") (_xrFoo r)
