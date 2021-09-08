-- | Query language
module Droplet.Language (spyQuery, module Exported) where

import Data.Maybe (Maybe)
import Droplet.Language.Internal.Condition (and, equals, isNotNull, notEquals, greaterThan, lesserThan, or, not, in_, Op, Not, In, Exists, (.&&.), (.<>.), (.=.), (.>.), (.<.), (.||.)) as Exported
import Droplet.Language.Internal.Definition (class FromValue, class ToParameters, class ToValue, Auto(..), E, Path, Default(..), Star(..), Table(..), star, fromValue, toValue, (...)) as Exported
import Droplet.Language.Internal.Function (count, string_agg, function, FunctionSignature, random) as Exported
import Droplet.Language.Internal.Query (class ToQuery, Query(..))
import Droplet.Language.Internal.Query as DLIQ
import Droplet.Language.Internal.Syntax (As, Inner, Outer, Delete, From, Insert, Into, OrderBy, Plan, Prepare, Select, Set, Update, Returning, Limit, Values, Where, as, delete, from, insert, into, orderBy, join, leftJoin, groupBy, Join, Offset, offset, Union, union, unionAll, On, Distinct, distinct, exists, prepare, select, set, asc, on, desc, update, limit, values, wher, returning) as Exported
import Droplet.Language.Internal.Syntax (Plan)
import Foreign (Foreign)

-- | Debug generated query
spyQuery ∷
      ∀ q projection.
      ToQuery q projection ⇒
      q →
      { parameters ∷ Array Foreign
      , plan ∷ Maybe Plan
      , query ∷ String
      }
spyQuery q = case DLIQ.query q of
      Query plan sql parameters → { plan, query: sql, parameters }