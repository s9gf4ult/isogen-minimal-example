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

-- | This instance is used in original code as hack to simplify code
-- generation
instance {-# OVERLAPPABLE #-} ToAttribute a where
  toAttribute _ = "Catchall attribute value"

mkNode :: (ToNode a, ToAttribute a) => a -> Node
mkNode a = Node (toNode a) (toAttribute a)
