module Test.NakedSelect where

import Droplet.Language
import Prelude
import Test.Types

import Data.Tuple.Nested ((/\))
import Droplet.Language.Internal.Query as Query
import Test.Model as TM
import Test.Unit (TestSuite)
import Test.Unit as TU
import Type.Proxy (Proxy(..))

--needs limit and all that
--subqueries need to have type Maybe
tests :: TestSuite
tests =
      TU.suite "naked select" do
            TU.test "scalar" do
                  let q = select (3 # as n)
                  TM.notParameterized "SELECT 3 AS n" $ Query.query q
                  TM.result q [{n : 3}]
            TU.test "sub query" do
                  let q = select (select (34 # as n) # from users # wher (name .=. name))
                  TM.notParameterized "SELECT (SELECT 34 AS n FROM users WHERE name = name)" $ Query.query q
                 -- TM.result q [{n : 34}, {n: 34}]
            TU.test "named sub query" do
                  let q = select (select (34 # as n) # from users # wher (name .=. name) # as t)
                  TM.notParameterized "SELECT (SELECT 34 AS n FROM users WHERE name = name) AS t" $ Query.query q
                  --TM.result q [{t : 34}, {t: 34}]
            TU.test "tuple" do
                  let q = select ((3 # as b) /\ (select (34 # as n) # from users # wher (name .=. surname) # as t) /\ (4 # as (Proxy :: Proxy "a")) /\ (select name # from users))
                  TM.notParameterized "SELECT 3 AS b, (SELECT 34 AS n FROM users WHERE name = surname) AS t, 4 AS a, (SELECT name FROM users)" $ Query.query q
                 -- TM.result q [{b: 3, n: 34, a : 4, name: "mary"}, {b: 3, n: 34, a : 4, name: "mary"}]
