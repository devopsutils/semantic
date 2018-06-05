{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Data.Abstract.ModuleTable
( ModulePath
, ModuleTable (..)
, singleton
, lookup
, member
, modulePathsInDir
, insert
, keys
, fromModules
, toPairs
) where

import Data.Abstract.Module
import qualified Data.Map as Map
import Data.Semigroup
import Data.Semilattice.Lower
import GHC.Generics (Generic1)
import Prelude hiding (lookup)
import Prologue
import System.FilePath.Posix

newtype ModuleTable a = ModuleTable { unModuleTable :: Map.Map ModulePath a }
  deriving (Eq, Foldable, Functor, Generic1, Lower, Monoid, Ord, Semigroup, Traversable)

singleton :: ModulePath -> a -> ModuleTable a
singleton name = ModuleTable . Map.singleton name

modulePathsInDir :: FilePath -> ModuleTable a -> [ModulePath]
modulePathsInDir k = filter (\e -> k == takeDirectory e) . Map.keys . unModuleTable

lookup :: ModulePath -> ModuleTable a -> Maybe a
lookup k = Map.lookup k . unModuleTable

member :: ModulePath -> ModuleTable a -> Bool
member k = Map.member k . unModuleTable

insert :: ModulePath -> a -> ModuleTable a -> ModuleTable a
insert k v = ModuleTable . Map.insert k v . unModuleTable

keys :: ModuleTable a -> [ModulePath]
keys = Map.keys . unModuleTable

-- | Construct a 'ModuleTable' from a non-empty list of 'Module's.
fromModules :: [Module term] -> ModuleTable (NonEmpty (Module term))
fromModules modules = ModuleTable (Map.fromListWith (<>) (fmap toEntry modules))
  where toEntry m = (modulePath (moduleInfo m), m:|[])

toPairs :: ModuleTable a -> [(ModulePath, a)]
toPairs = Map.toList . unModuleTable


instance Show a => Show (ModuleTable a) where
  showsPrec d = showsUnaryWith showsPrec "ModuleTable" d . toPairs
