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

-- | This instance is used in original code as hack to simplify code
-- generation
instance {-# OVERLAPPABLE #-} ToAttribute a where
  toAttribute _ = "Catchall attribute value"
