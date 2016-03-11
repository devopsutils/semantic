{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Data.Adjoined where

import Control.Monad
import Data.Coalescent
import Data.Sequence as Seq

newtype Adjoined a = Adjoined { unAdjoined :: Seq a }
  deriving (Eq, Foldable, Functor, Show, Traversable)

fromList :: [a] -> Adjoined a
fromList = Adjoined . Seq.fromList

instance Applicative Adjoined where
  pure = return
  (<*>) = ap

instance Monad Adjoined where
  return = Adjoined . return
  Adjoined a >>= f = case viewl a of
    EmptyL -> Adjoined Seq.empty
    (a :< as) -> Adjoined $ unAdjoined (f a) >< unAdjoined (Adjoined as >>= f)

instance Coalescent a => Monoid (Adjoined a) where
  mempty = Adjoined mempty
  Adjoined a `mappend` Adjoined b | as :> a' <- viewr a, b' :< bs <- viewl b, Just coalesced <- coalesce a' b' = Adjoined (as >< (coalesced <| bs))
                                  | otherwise = Adjoined (a >< b)
