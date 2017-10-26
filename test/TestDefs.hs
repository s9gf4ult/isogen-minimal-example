{-# OPTIONS -ddump-splices #-}

module TestDefs where

import Data.Maybe
import Data.Text as T
import ExternalStuff
import GHC.Generics (Generic)
import Text.XML.Node
import Text.XML.ParentAttributes

data XmlFoo = XmlFoo
  { _xfQuux :: Text
    -- ^ This is in fact an attribute, not tag
  } deriving (Generic, Show, Eq)

instance WriteNodes XmlFoo where
  toXML _ = return ()

instance ToXmlParentAttributes XmlFoo where
  toXmlParentAttributes f =
    mapMaybe distribPair [("Quux", (Just . toXmlAttribute) (_xfQuux f))]

instance FromDom XmlFoo where
  fromDom = pure XmlFoo
    <*> parseAttribute "Quux" fromAttribute

data XmlRoot = XmlRoot
  { _xrFoo :: XmlFoo
  } deriving (Generic, Show, Eq)

instance ToXML XmlRoot where
  toXML r = return () *> id (mkElement "Foo") (_xrFoo r)

instance FromDom XmlRoot where
  fromDom = pure XmlRoot
    <*> inElem "Foo" fromDom
