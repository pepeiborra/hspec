-----------------------------------------------------------------------------
--
-- Module      :  Specs
-- Copyright   :  (c) Trystan Spangler 2011
-- License     :  modified BSD
--
-- Maintainer  : trystan.s@comcast.net
-- Stability   : experimental
-- Portability : portable
--
-- |
--
-----------------------------------------------------------------------------

module Specs where

import Test.Hspec.Internal
import Test.Hspec.QuickCheck
import Test.Hspec.HUnit ()
import System.IO
import System.Environment
import Control.Monad (liftM)
import qualified Test.HUnit as Hunit

main :: IO ()
main = do
  ar <- getArgs
  case ar of
    ["README"] -> withFile "README" WriteMode (\ h -> hPutStrLn h preable >> hHspec h specs)
    [filename] -> withFile filename WriteMode (\ h -> hHspec h specs)
    _          -> hspec specs

preable :: String
preable = unlines [
    "hspec aims to be a simple, extendable, and useful tool for Behavior Driven Development in Haskell.", "",
    "",
    "Step 1, write your specs",
    "> specs = describe \"myabs\" [",
    ">   it \"returns the original number when given a positive input\"",
    ">     (myabs 1 == 1),",
    "> ",
    ">   it \"returns a positive number when given a negative input\"",
    ">     (myabs (-1) == 1),",
    "> ",
    ">   it \"returns zero when given zero\"",
    ">     (myabs 0 == 0)",
    ">   ]",
    "",
    "Step 2, write your dummy function",
    "> myabs n = undefined",
    "",
    "Step 3, watch them fail",
    "> hspec specs",
    "myabs",
    " x returns the original number when given a positive input (Prelude.undefined)",
    " x returns a positive number when given a negative input (Prelude.undefined)",
    " x returns zero when given zero (Prelude.undefined)",
    "",
    "Finished in 0.0002 seconds",
    "",
    "3 examples, 3 failures",
    "",
    "Step 4, implement your requirements",
    "> myabs n = if n < 0 then negate n else n", "",
    "Step 5, watch them pass",
    "> hspec specs",
    "myabs",
    " - returns the original number when given a positive input",
    " - returns a positive number when given a negative input",
    " - returns zero when given zero",
    "",
    "Finished in 0.0000 seconds",
    "",
    "3 examples, 0 failures",
    "",
    "",
    "",
    "",
    "Here's the report of hspec's specs:" ]

specs :: IO [Spec]
specs = let spec = Spec "Example" "example"
            testSpecs = [spec Success, spec (Fail ""), spec (Pending "")]
        in liftM concat $ sequence [

  describe "describe" [
    it "takes a description of what the requirements are for"
        ((=="Example") . name . head $ testSpecs),

    it "groups requirements for what's being described"
        (all ((=="Example").name) testSpecs)
  ],
  describe "it" [
    it "takes the description of the requirement"
        (requirement (Spec "Example" "whatever" Success) == "whatever" ),

    it "takes the verification that the description was implemented"
        (result (spec Success) == Success),

    it "can use a Bool, HUnit Test, QuickCheck propertie, or \"pending\" as a verifier"
        (True),

    it "will treat exceptions as failures"
        (Hunit.TestCase $ do
          innerSpecs <- describe "" [ it "exceptions" (True && undefined)]
          let found = pureHspec innerSpecs !! 2
          Hunit.assertEqual (unlines $ pureHspec innerSpecs) " x exceptions (Prelude.undefined)" found),

    it "allows failures to have details"
        (const True (Fail "details"))
  ],
  describe "Bool verifier" [
    it "is just an expression that evaluates to a Bool"
        (True)
  ],
  describe "HUnit verifier" [
    it "allows an HUnit test case with assertions to act as verification"
        (True),

    it "is specified with the HUnit \"TestCase\" data constructor"
        (Hunit.TestCase $ Hunit.assertBool "example" True),

    it "is the assumed verifier for IO() actions"
        (Hunit.assertBool "example" True),

    it "will show the assertion text if it fails"
        (Hunit.TestCase $ do
          innerSpecs <- describe "" [ it "fails" (Hunit.assertBool "trivial" False)]
          let found = pureHspec innerSpecs !! 2
          Hunit.assertEqual found " x fails (trivial)" found)
  ],
  describe "QuickCheck verifier" [
    it "allows a QuickCheck property to act as verification"
        (True),

    it "is specified with the \"property\" function"
        (property $ \ b -> b || True)
  ],
  describe "pending verifier" [
    it "allows a requirement to be pending verification"
        (True),

    it "is specified with the \"pending\" function and an explination"
        (pending "message" == Pending "message"),

    it "accepts a message to display in the report"
        (documentSpec (spec (Pending "t")) == " - example\n     # t")
  ],
  describe "hspec" [
    it "displays each thing being described as a header"
        (documentGroup [spec Success] !! 1 == "Example"),

    it "displays one row for each requirement"
        (length (documentGroup testSpecs) == 5),

    it "displays a '-' for successfully implemented requirements"
        (documentSpec (spec Success) == " - example"),

    it "displays an 'x' for unsuccessfully implmented requirements"
        (documentSpec (spec $ Fail "whatever") == " x example (whatever)" ),

    it "displays optional details for unsuccessfully implmented requirements"
        (documentSpec (spec $ Fail "whatever") == " x example (whatever)" ),

    it "displays a '-' for pending requirements"
        (documentSpec (spec (Pending "pending")) == " - example\n     # pending" ),

    it "displays a '#' and an additional message for pending requirements"
        (documentSpec (spec (Pending "pending")) == " - example\n     # pending" ),

    it "can output to stdout"
        (True),

    it "can output to stdout in color"
        (pending "TODO in the near future, perhaps using System.Console.ANSI?"),

    it "summarizes the time it takes to finish"
        (any (=="Finished in 0.0000 seconds") (pureHspec testSpecs)),

    it "summarizes the number of examples and failures"
        (any (=="3 examples, 1 failure") (pureHspec testSpecs))
  ],
  describe "quantify (an internal function)" [
    it "returns an amount and a word given an amount and word"
        (quantify (1::Int) "thing" == "1 thing"),

    it "returns a singular word given the number 1"
        (quantify (1::Int) "thing" == "1 thing"),

    it "returns a plural word given a number greater than 1"
        (quantify (2::Int) "thing" == "2 things"),

    it "returns a plural word given the number 0"
        (quantify (0::Int) "thing" == "0 things")
  ]]
