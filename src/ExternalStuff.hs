module ExternalStuff where

import Data.List.NonEmpty
import Data.Maybe
import Data.Text as T
import GHC.Generics (Generic)
import Text.XML.Node
import Text.XML.ParentAttributes

mkElement
  :: (WriteNodes a, ToAttribute a)
  => Text
  -> a
  -> [(Text, Node)]
mkElement name a = [(name, Node (writeNodes a) (toAttribute a))]
