module ExternalStuff where

import Data.List.NonEmpty
import Data.Maybe
import Data.Text as T
import GHC.Generics (Generic)

mkElement :: (WriteNodes a, ToXmlParentAttributes a) => Name -> a -> XML
mkElement name a = elementA name (toXmlParentAttributes a) a

distribPair :: Functor f => (a, f b) -> f (a, b)
distribPair (a, fb) = (a,) <$> fb
