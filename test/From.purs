module Test.From where

import Droplet.Language
import Prelude hiding (join)
import Test.Types

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Droplet.Language.Internal.Query as Query
import Test.Model as TM
import Test.Unit (TestSuite)
import Test.Unit as TU
import Type.Proxy (Proxy(..))

tests ∷ TestSuite
tests = do
      TU.suite "from" do
            TU.test "table" do
                  let q = select star # from messages
                  TM.notParameterized """SELECT * FROM messages""" $ Query.query q
                  TM.result' q []
            TU.test "null fields" do
                  let q = select (created /\ _by) # from tags
                  TM.notParameterized """SELECT created, by FROM tags""" $ Query.query q
                  TM.result q [ { created: Nothing, by: Just 1 } ]
            TU.suite "named table" do
                  TU.test "path" do
                        let q = select (u ... id) # from (users # as u)
                        TM.notParameterized """SELECT "u"."id" "u.id" FROM users AS "u"""" $ Query.query q
                        TM.result q [ { "u.id": 1 }, { "u.id": 2 } ]
                  TU.test "aliased path" do
                        let q = select (u ... id # as id) # from (users # as u)
                        TM.notParameterized """SELECT "u"."id" AS "id" FROM users AS "u"""" $ Query.query q
                        TM.result q [ { id: 1 }, { id: 2 } ]
            TU.suite "named queries" do
                  TU.test "star" do
                        let q = select star # from (select (4 # as n) # from messages # as n)
                        TM.notParameterized """SELECT * FROM (SELECT 4 AS "n" FROM messages) AS "n"""" $ Query.query q
                        TM.result q [ { n: 4 }, { n: 4 } ]
                  TU.test "star qualified qualified field" do
                        let q = select star # from (select (bigB ... birthday) # from (users # as bigB) # as t)
                        TM.notParameterized """SELECT * FROM (SELECT "B"."birthday" "B.birthday" FROM users AS "B") AS "t"""" $ Query.query q
                        TM.result q [ { "B.birthday": TM.makeDate 1990 1 1 }, { "B.birthday": TM.makeDate 1900 11 11 } ]
                  TU.test "field" do
                        let q = select birthday # from (select birthday # from users # as t)
                        TM.notParameterized """SELECT birthday FROM (SELECT birthday FROM users) AS "t"""" $ Query.query q
                        TM.result q [ { birthday: TM.makeDate 1990 1 1 }, { birthday: TM.makeDate 1900 11 11 } ]
                  TU.test "qualified field" do
                        let q = select (t ... birthday) # from (select birthday # from users # as t)
                        TM.notParameterized """SELECT "t"."birthday" "t.birthday" FROM (SELECT birthday FROM users) AS "t"""" $ Query.query q
                        TM.result q [ { "t.birthday": TM.makeDate 1990 1 1 }, { "t.birthday": TM.makeDate 1900 11 11 } ]
                  TU.test "qualified qualified field" do
                        let q = select (t ... (Proxy ∷ Proxy "B.birthday")) # from (select (bigB ... birthday) # from (users # as bigB) # as t)
                        TM.notParameterized """SELECT "t"."B.birthday" "t.B.birthday" FROM (SELECT "B"."birthday" "B.birthday" FROM users AS "B") AS "t"""" $ Query.query q
                        TM.result q [ { "t.B.birthday": TM.makeDate 1990 1 1 }, { "t.B.birthday": TM.makeDate 1900 11 11 } ]
                  TU.test "renamed field" do
                        let q = select t # from (select (birthday # as t) # from users # as t)
                        TM.notParameterized """SELECT t FROM (SELECT birthday AS "t" FROM users) AS "t"""" $ Query.query q
                        TM.result q [ { t: TM.makeDate 1990 1 1 }, { t: TM.makeDate 1900 11 11 } ]
                  TU.test "join" do
                        let q = select star # from (select (u ... name /\ t ... id) # from (join (users # as u) (messages # as t) # on (u ... id .=. t ... id)) # as b)
                        TM.notParameterized """SELECT * FROM (SELECT "u"."name" "u.name", "t"."id" "t.id" FROM users AS "u" INNER JOIN messages AS "t" ON "u"."id" = "t"."id") AS "b"""" $ Query.query q
                        TM.result q [ { "t.id": 1, "u.name": "josh" }, { "t.id": 2, "u.name": "mary" } ]