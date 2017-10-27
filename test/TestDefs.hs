{-# OPTIONS -ddump-splices #-}

module TestDefs where

import Data.Text as T
import ExternalStuff
import GHC.Generics (Generic)

data XmlFoo = XmlFoo deriving (Generic, Show, Eq)

instance ToNode XmlFoo where
  toNode _ = Nothing

instance ToAttribute XmlFoo where
  toAttribute _ = "Value from right instance"

data XmlRoot = XmlRoot
  { _xrFoo :: XmlFoo
  } deriving (Generic, Show, Eq)

instance ToNode XmlRoot where
  toNode r = Just $ mkNode (_xrFoo r)
