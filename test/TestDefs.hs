{-# OPTIONS -ddump-splices #-}

module TestDefs where

import Data.List.NonEmpty
import Data.Maybe
import Data.Text as T
import ExternalStuff
import GHC.Generics (Generic)
import Test.QuickCheck.Arbitrary.Generic
import Test.QuickCheck.Instances ()
import Text.XML
import Text.XML.DOM.Parser
import Text.XML.ParentAttributes
import Text.XML.Writer


mkElement :: (ToXML a, ToXmlParentAttributes a) => Name -> a -> XML
mkElement name a = elementA name (toXmlParentAttributes a) a

data XmlFoo = XmlFoo
  { _xfQuux :: Text
    -- ^ This is in fact an attribute, not tag
  } deriving (Generic, Show, Eq)

instance Arbitrary XmlFoo where
  arbitrary = genericArbitrary
  shrink = genericShrink

instance ToXML XmlFoo where
  toXML f = return ()

instance ToXmlParentAttributes XmlFoo where
  toXmlParentAttributes f =
    mapMaybe distribPair [("Quux", (Just . toXmlAttribute) (_xfQuux f))]

instance FromDom XmlFoo where
  fromDom = pure XmlFoo
    <*> parseAttribute "Quux" fromAttribute

data XmlRoot = XmlRoot
  { _xrFoo :: XmlFoo
  } deriving (Generic, Show, Eq)

instance Arbitrary XmlRoot where
  arbitrary = genericArbitrary
  shrink = genericShrink

instance ToXML XmlRoot where
  toXML r = return () *> id (mkElement "Foo") (_xrFoo r)

instance FromDom XmlRoot where
  fromDom = pure XmlRoot
    <*> inElem "Foo" fromDom
