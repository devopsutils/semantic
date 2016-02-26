{-# LANGUAGE UndecidableInstances #-}
module Control.Comonad.Cofree where

data Cofree functor annotation = annotation :< (functor (Cofree functor annotation))
  deriving (Functor, Foldable, Traversable)

instance (Eq annotation, Eq (functor (Cofree functor annotation))) => Eq (Cofree functor annotation) where
  a :< f == b :< g = a == b && f == g
