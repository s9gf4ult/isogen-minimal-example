module Text.XML.Node where

import Control.Lens
import Control.Monad.Writer
import Data.Text as T

data Node
  = Node
  { _nodeChilds     :: [(Text, Node)]
  , _nodeAttributes :: [(Text, Text)] }
  deriving (Show)

makeLenses ''Node

type NodeWriter = Writer [(Text, Node)]

class WriteNodes a where
  writeNodes  :: a -> NodeWriter ()

render :: NodeWriter () -> [(Text, Node)]
render w = snd $ runWriter w

node :: Text -> [(Text, Text)] -> NodeWriter () -> NodeWriter ()
node name attrs childs = tell $ [(name, Node (render childs) attrs)]

named :: Text -> Traversal' (Text, a) a
named expected = filtered expName . _2
  where
    expName (name, _) = name == expected
