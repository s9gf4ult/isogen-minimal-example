module ExternalStuff where

import Data.List.NonEmpty
import Data.Maybe
import Data.Text as T
import GHC.Generics (Generic)
import Text.XML.Node
import Text.XML.ParentAttributes

mkElement
  :: (WriteNodes a, ToXmlParentAttributes a)
  => Text
  -> a
  -> NodeWriter ()
mkElement name a = node name (toXmlParentAttributes a) (writeNodes a)

distribPair :: Functor f => (a, f b) -> f (a, b)
distribPair (a, fb) = (a,) <$> fb
