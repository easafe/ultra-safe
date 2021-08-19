-- | Logical operators for filtering records
-- |
-- | Do not import this module directly, it will break your code and make it not type safe. Use the sanitized `Droplet.Language` instead
module Droplet.Language.Internal.Condition (class ToCondition, class ValidComparision, OuterScope, class Comparision, Op(..), IsNotNull(..), isNotNull, in_, and, Exists(..), Not(..), not, BinaryOperator(..), equals, notEquals, greaterThan, lesserThan, or, (.&&.), (.<>.), (.=.), (.||.), (.<.), (.>.)) where

import Prelude

import Data.Maybe (Maybe(..))
import Droplet.Language.Internal.Definition (class ToValue, class UnwrapDefinition, class UnwrapNullable, Path)
import Prim.Row (class Cons)
import Type.Proxy (Proxy)


data BinaryOperator =
      Equals |
      NotEquals |
      GreaterThan |
      LesserThan |
      And |
      Or  |
      In -- only for arrays

data Exists = Exists

data Not = Not

data IsNotNull = IsNotNull

derive instance Eq BinaryOperator

-- | Wrapper for comparisions
data Op b c = Op (Maybe BinaryOperator) b c

data OuterScope


-- | SQL logical expressions
class ToCondition (c :: Type) (fields :: Row Type) (alias :: Symbol)

-- | AND/OR
instance (ToCondition (Op a b) fields alias, ToCondition (Op c d) fields alias) => ToCondition (Op (Op a b) (Op c d)) fields alias

-- | EXISTS
else instance ToCondition (Op Exists b) fields alias

-- | IS NOT NULL
else instance Cons name (Maybe t) d fields => ToCondition (Op IsNotNull (Proxy name)) fields alias

else instance Cons name (Maybe t) d fields => ToCondition (Op IsNotNull (Path alias name)) fields alias

else instance ToCondition (Op IsNotNull (Path table name)) fields alias

-- | NOT
else instance ToCondition a fields alias => ToCondition (Op Not a) fields alias

-- | Comparisions
else instance (
      Comparision a fields alias t,
      Comparision b fields alias u,
      ValidComparision t u
) => ToCondition (Op a b) fields alias


-- | Whether expression can be compared
class Comparision (c :: Type) (fields :: Row Type) (alias :: Symbol) (t :: Type) | c -> fields t

instance (Cons name t d fields, UnwrapDefinition t u) => Comparision (Proxy name) fields alias u

else instance (
      Cons name t d fields,
      UnwrapDefinition t u,
      UnwrapNullable u v
) => Comparision (Path alias name) fields alias v

else instance Comparision (Path table name) fields alias OuterScope

-- | IN values
else instance Comparision (Array t) fields alias t

else instance ToValue t => Comparision t fields alias t


-- | Helper to cut down on `Comparision` instances
class ValidComparision (t :: Type) (u :: Type)

instance ValidComparision t OuterScope

else instance ValidComparision OuterScope t

else instance ValidComparision t t


equals :: forall field compared. field -> compared -> Op field compared
equals field compared = Op (Just Equals) field compared

notEquals :: forall compared field. field -> compared -> Op field compared
notEquals field compared = Op (Just NotEquals) field compared

greaterThan :: forall compared field. field -> compared -> Op field compared
greaterThan field compared = Op (Just GreaterThan) field compared

lesserThan :: forall compared field. field -> compared -> Op field compared
lesserThan field compared = Op (Just LesserThan) field compared

and :: forall a b c d. Op a b -> Op c d -> Op (Op a b) (Op c d)
and first second = Op (Just And) first second

or :: forall a b c d. Op a b -> Op c d -> Op (Op a b) (Op c d)
or first second = Op (Just Or) first second

in_ :: forall compared field. field -> compared -> Op field compared
in_ field compared = Op (Just In) field compared

not :: forall compared field. Op field compared -> Op Not (Op field compared)
not a = Op Nothing Not a

isNotNull :: forall field. field -> Op IsNotNull field
isNotNull field = Op Nothing IsNotNull field

infix 4 notEquals as .<>.
infix 4 equals as .=.
infix 4 greaterThan as .>.
infix 4 lesserThan as .<.
infixl 3 and as .&&.
infixl 2 or as .||.
