{-# LANGUAGE MonoLocalBinds #-}

module ExternalStuff where

class ToString a where
  toString :: a -> String

toString' :: (ToString a) => a -> String
toString' = toString
