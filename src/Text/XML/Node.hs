module Text.XML.Node where

import Control.Monad.Writer
import Data.Text as T

data Node
  = Node
  { nodeChilds     :: [(Text, Node)]
  , nodeAttributes :: [(Text, Text)] }
  | Leaf Text
  deriving (Show)

type NodeWriter = Writer [(Text, Node)]

class WriteNodes a where
  writeNodes  :: a -> NodeWriter ()

render :: NodeWriter () -> [(Text, Node)]
render w = snd $ runWriter w

node :: Text -> [(Text, Text)] -> NodeWriter () -> NodeWriter ()
node name attrs childs = tell $ [(name, Node (render childs) attrs)]
