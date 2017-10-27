{-# OPTIONS -ddump-splices #-}

module TestDefs where

import Data.Maybe
import Data.Text as T
import ExternalStuff
import GHC.Generics (Generic)
import Text.XML.Node
import Text.XML.ParentAttributes

mkElement
  :: (WriteNodes a, ToXmlParentAttributes a)
  => Text
  -> a
  -> NodeWriter ()
mkElement name a = node name (toXmlParentAttributes a) (writeNodes a)


data XmlFoo = XmlFoo
  { _xfQuux :: Text
    -- ^ This is in fact an attribute, not tag
  } deriving (Generic, Show, Eq)

instance WriteNodes XmlFoo where
  writeNodes _ = return ()

instance ToXmlParentAttributes XmlFoo where
  toXmlParentAttributes f =
    mapMaybe distribPair [("Quux", (Just . toXmlAttribute) (_xfQuux f))]

data XmlRoot = XmlRoot
  { _xrFoo :: XmlFoo
  } deriving (Generic, Show, Eq)

instance WriteNodes XmlRoot where
  writeNodes r = return () *> id (mkElement "Foo") (_xrFoo r)
