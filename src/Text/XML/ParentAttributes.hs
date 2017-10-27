module Text.XML.ParentAttributes
  ( ToAttribute(..)
  ) where

import Data.Text as T
import Numeric.Natural

class ToAttribute a where
  toAttribute :: a -> Text

-- | This instance is used in original code as hack to simplify code
-- generation
instance {-# OVERLAPPABLE #-} ToAttribute a where
  toAttribute _ = "Catchall attribute value"
