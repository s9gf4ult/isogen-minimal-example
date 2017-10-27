module ExternalStuff where

import Data.Text as T

data Node = Node
  { nodeChild     :: Maybe Node
  , nodeAttribute :: Text
  } deriving (Show)

class ToNode a where
  toNode  :: a -> Maybe Node

class ToAttribute a where
  toAttribute :: a -> Text

mkNode :: (ToNode a, ToAttribute a) => a -> Node
mkNode a = Node (toNode a) (toAttribute a)
