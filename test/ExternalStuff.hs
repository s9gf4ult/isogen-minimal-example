module ExternalStuff where

import Data.Text as T

class ToText a where
  toText :: a -> Text

-- | This instance is used in original code as hack to simplify code
-- generation
instance {-# OVERLAPPABLE #-} ToText a where
  toText _ = "Catchall attribute value"
