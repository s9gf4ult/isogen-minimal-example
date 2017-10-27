module ExternalStuff where

import Data.Text as T

class ToText a where
  toText :: a -> Text

toTextProxy :: (ToText a) => a -> Text
toTextProxy a = toText a
