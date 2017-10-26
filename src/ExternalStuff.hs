module ExternalStuff where

import Data.List.NonEmpty
import Data.Maybe
import Data.Text as T
import GHC.Generics (Generic)
import Text.XML
import Text.XML.DOM.Parser
import Text.XML.ParentAttributes
import Text.XML.Writer

distribPair :: Functor f => (a, f b) -> f (a, b)
distribPair (a, fb) = (a,) <$> fb
