{-# LANGUAGE MonoLocalBinds #-}

module ExternalStuff where

class ToString a where
  toString :: a -> String

-- | This instance is used in original code as hack to simplify code
-- generation
instance {-# OVERLAPPABLE #-} ToString a where
  toString _ = "Catchall attribute value"
