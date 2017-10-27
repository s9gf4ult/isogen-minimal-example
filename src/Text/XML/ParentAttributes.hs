module Text.XML.ParentAttributes
  ( ToAttribute(..)
  ) where

import Data.Text as T
import Numeric.Natural

class ToAttribute a where
  toAttribute :: a -> Text
