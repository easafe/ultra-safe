module Test.Update where

import Droplet.Language
import Droplet.Language
import Prelude
import Test.Types

import Data.Tuple.Nested ((/\))
import Droplet.Language.Internal.Translate as DLIQ
import Test.Model as TM
import Test.Unit (TestSuite)
import Test.Unit as TU

tests ∷ TestSuite
tests = do
      TU.suite "set" do
            TU.test "single field" do
                  let q = update users # set (surname .=. "Sue")
                  TM.parameterized """UPDATE users SET surname = $1""" $ DLIQ.buildQuery q
                  TM.result q []
            TU.test "fields" do
                  let q = update users # set ((name .=. "Mary") /\ (surname .=. "Sue"))
                  TM.parameterized """UPDATE users SET name = $1, surname = $2""" $ DLIQ.buildQuery q
                  TM.result q []
            TU.test "default" do
                  let q = update users # set ((name .=. "Mary") /\ (birthday .=. Default))
                  TM.parameterized """UPDATE users SET name = $1, birthday = DEFAULT""" $ DLIQ.buildQuery q
                  TM.result q []
      TU.suite "where" do
            TU.test "single field" do
                  let q = update users # set (surname .=. "Sue") # wher (id .=. 1)
                  TM.parameterized """UPDATE users SET surname = $1 WHERE "id" = $2""" $ DLIQ.buildQuery q
                  TM.result q []
            TU.test "fields" do
                  let q = update users # set ((name .=. "Mary") /\ (surname .=. "Sue")) # wher (id .=. 2 .||. id .=. 4)
                  TM.parameterized """UPDATE users SET name = $1, surname = $2 WHERE ("id" = $3 OR "id" = $4)""" $ DLIQ.buildQuery q
                  TM.result q []
