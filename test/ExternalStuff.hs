module ExternalStuff where

import Data.Text as T

data Node = Node
  { nodeAttribute :: Text
  } deriving (Show)

class ToNode a where
  toNode  :: a -> Node

class ToAttribute a where
  toAttribute :: a -> Text

-- | This instance is used in original code as hack to simplify code
-- generation
instance {-# OVERLAPPABLE #-} ToAttribute a where
  toAttribute _ = "Catchall attribute value"

mkNode :: (ToAttribute a) => a -> Node
mkNode a = Node (toAttribute a)
