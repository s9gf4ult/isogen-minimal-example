module Text.XML.Node where

import Control.Lens
import Control.Monad.Writer
import Data.Text as T

data Node
  = Node
  { _nodeChilds    :: [(Text, Node)]
  , _nodeAttribute :: Text }
  deriving (Show)

makeLenses ''Node

class WriteNodes a where
  writeNodes  :: a -> [(Text, Node)]

named :: Text -> Traversal' (Text, a) a
named expected = filtered expName . _2
  where
    expName (name, _) = name == expected
