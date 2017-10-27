module ExternalStuff where

import Control.Lens
import Data.Text as T

data Node = Node
  { _nodeChild     :: Maybe Node
  , _nodeAttribute :: Text
  } deriving (Show)

makeLenses ''Node

class ToNode a where
  toNode  :: a -> Maybe Node

class ToAttribute a where
  toAttribute :: a -> Text

mkNode :: (ToNode a, ToAttribute a) => a -> Node
mkNode a = Node (toNode a) (toAttribute a)
