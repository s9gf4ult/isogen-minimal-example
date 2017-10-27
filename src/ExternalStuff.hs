module ExternalStuff where

import Control.Lens
import Data.List.NonEmpty
import Data.Maybe
import Data.Text as T
import GHC.Generics (Generic)

data Node
  = Node
  { _nodeChilds    :: [(Text, Node)]
  , _nodeAttribute :: Text }
  deriving (Show)

makeLenses ''Node

class WriteNodes a where
  writeNodes  :: a -> [(Text, Node)]

class ToAttribute a where
  toAttribute :: a -> Text

mkElement
  :: (WriteNodes a, ToAttribute a)
  => Text
  -> a
  -> [(Text, Node)]
mkElement name a = [(name, Node (writeNodes a) (toAttribute a))]
