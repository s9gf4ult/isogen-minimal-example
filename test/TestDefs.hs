{-# OPTIONS -ddump-splices #-}

module TestDefs where

import Data.Text as T
import ExternalStuff
import GHC.Generics (Generic)

data XmlFoo = XmlFoo
  { _xfQuux :: Text
    -- ^ This is in fact an attribute, not tag
  } deriving (Generic, Show, Eq)

instance WriteNodes XmlFoo where
  writeNodes _ = []

instance ToAttribute XmlFoo where
  toAttribute = _xfQuux

data XmlRoot = XmlRoot
  { _xrFoo :: XmlFoo
  } deriving (Generic, Show, Eq)

instance WriteNodes XmlRoot where
  writeNodes r = id (\a -> [("Foo", Node (writeNodes a) (toAttribute a))]) (_xrFoo r)
