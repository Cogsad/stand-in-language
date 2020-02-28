module ParserTests where

import SIL.Parser
import Test.Tasty
import Test.Tasty.HUnit
import Text.Megaparsec.Error
import Text.Megaparsec
import Text.Megaparsec.Debug
import qualified Data.Map as Map
import qualified SIL.Parser as Parsec
import qualified System.IO.Strict as Strict
import qualified Control.Monad.State as State

main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests" [unitTests]

unitTests = testGroup "Unit tests"
  [ testCase "test Pair 0" $ do
      res <- runTestPair testPair0
      res `compare` testPair0ParsecResult @?= EQ
  ,testCase "test ITE 1" $ do
      res <- runTestITE testITE1
      res `compare` testITEParsecResult @?= EQ
  , testCase "test ITE 2" $ do
      res <- runTestITE testITE2
      res `compare` testITEParsecResult @?= EQ
  , testCase "test ITE 3" $ do
      res <- runTestITE testITE3
      res `compare` testITEParsecResult @?= EQ
    -- Maybe TODO: Maybe Fix
    -- Probably thinks "then" is part of an assignment
  , testCase "test ITE 4" $ do
      res <- runTestITE testITE4
      res `compare` testITEParsecResult @?= EQ
  , testCase "test ITE with Pair" $ do
      res <- runSILParser parseITE testITEwPair
      res `compare` testITEWPairParsecResult @?= EQ
  , testCase "test if Complete Lambda with ITE Pair parses successfuly" $ do
      res <- parseSuccessful parseCompleteLambda testCompleteLambdawITEwPair
      res `compare` True @?= EQ
  , testCase "test if Lambda with ITE Pair parses successfuly" $ do
      res <- parseSuccessful parseLambda testLambdawITEwPair
      res `compare` True @?= EQ
  , testCase "test parse assignment with Complete Lambda with ITE with Pair" $ do
      res <- runSILParser parseAssignment testParseAssignmentwCLwITEwPair1
      res `compare` testParseAssignmentwCLwITEwPair1ParsecResult @?= EQ
  , testCase "test if testParseTopLevelwCLwITEwPair parses successfuly" $ do
      res <- parseSuccessful parseTopLevel testParseTopLevelwCLwITEwPair
      res `compare` True @?= EQ
  , testCase "test parseMain with CL with ITE with Pair parses" $ do
      res <- runTestMainwCLwITEwPair
      res `compare` True @?= EQ
  , testCase "testList0" $ do
      res <- runSILParser parseList testList0
      res `compare` testListAns @?= EQ
  , testCase "testList1" $ do
      res <- runSILParser parseList testList1
      res `compare` testListAns @?= EQ
  , testCase "testList2" $ do
      res <- runSILParser parseList testList2
      res `compare` testListAns @?= EQ
  , testCase "testList3" $ do
      res <- runSILParser parseList testList3
      res `compare` testListAns @?= EQ
  , testCase "testList4" $ do
      res <- runSILParser parseList testList4
      res `compare` testListAns @?= EQ
  , testCase "testList5" $ do
      res <- runSILParser parseList testList5
      res `compare` testListAns @?= EQ
  , testCase "test parse Prelude.sil" $ do
      res <- runTestParsePrelude
      res `compare` True @?= EQ
  , testCase "test parse tictactoe.sil" $ do
      res <- testWtictactoe
      res `compare` True @?= EQ
  , testCase "test Main with Type" $ do
      res <- runTestMainWType
      res `compare` True @?= EQ
  ]


runTestPair :: String -> IO String
runTestPair = runSILParser parsePair

testPair0 = "{\"Hello World!\", \"0\"}"

testPair1 = unlines
  [ "{"
  , " \"Hello World!\""
  , ", \"0\""
  , "}"
  ]

runTestITE :: String -> IO String
runTestITE = runSILParser parseITE

testITE1 = unlines $
  [ "if"
  , "  1"
  , "then 1"
  , "else"
  , "  2"
  ]
testITE2 = unlines $
  [ "if 1"
  , "  then"
  , "                1"
  , "              else 2"
  ]
testITE3 = unlines $
  [ "if 1"
  , "   then"
  , "                1"
  , "              else 2"
  ]
testITE4 = unlines $
  [ "if 1"
  , "    then"
  , "                1"
  , "              else 2"
  ]

testITEwPair = unlines $
  [ "if"
  , "    1"
  , "  then {\"Hello, world!\", 0}"
  , "  else"
  , "    {\"Goodbye, world!\", 1}"
  ]

testCompleteLambdawITEwPair = unlines $
  [ "#input ->"
  , "  if"
  , "    1"
  , "   then {\"Hello, world!\", 0}"
  , "   else"
  , "    {\"Goodbye, world!\", 1}"
  ]

testIfParseSuccessful p str = do
  preludeFile <- Strict.readFile "Prelude.sil"
  case p str of
    Right _ -> return True
    Left _ -> return False


testLambdawITEwPair = unlines $
  [ "\\input ->"
  , "  if"
  , "    1"
  , "   then {\"Hello, world!\", 0}"
  , "   else"
  , "    {\"Goodbye, world!\", 1}"
  ]

runTestParsePrelude = do
  preludeFile <- Strict.readFile "Prelude.sil"
  case parsePrelude preludeFile of
    Right _ -> return True
    Left _ -> return False

testParseAssignmentwCLwITEwPair2 = unlines $
  [ "main = #input -> if 1"
  , "                  then"
  , "                   {\"Hello, world!\", 0}"
  , "                  else {\"Goodbye, world!\", 0}"
  ]
testParseAssignmentwCLwITEwPair3 = unlines $
  [ "main = #input ->"
  , "  if 1"
  , "   then"
  , "     {\"Hello, world!\", 0}"
  , "   else {\"Goodbye, world!\", 0}"
  ]
testParseAssignmentwCLwITEwPair4 = unlines $
  [ "main = #input"
  , "-> if 1"
  , "    then"
  , "       {\"Hello, world!\", 0}"
  , "      else {\"Goodbye, world!\", 0}"
  ]
testParseAssignmentwCLwITEwPair5 = unlines $
  [ "main"
  , "  = #input"
  , "-> if 1"
  , "    then"
  , "       {\"Hello, world!\", 0}"
  , "      else {\"Goodbye, world!\", 0}"
  ]
testParseAssignmentwCLwITEwPair6 = unlines $
  [ "main"
  , "  = #input"
  , " -> if 1"
  , "    then"
  , "       {\"Hello, world!\", 0}"
  , "      else {\"Goodbye, world!\", 0}"
  ]
testParseAssignmentwCLwITEwPair7 = unlines $
  [ "main"
  , "  = #input"
  , " -> if 1"
  , "       then"
  , "             {\"Hello, world!\", 0}"
  , "           else {\"Goodbye, world!\", 0}"
  ]
testParseAssignmentwCLwITEwPair1 = unlines $
  [ "main"
  , "  = #input"
  , " -> if 1"
  , "     then"
  , "       {\"Hello, world!\", 0}"
  , "     else {\"Goodbye, world!\", 0}"
  ]

testParseTopLevelwCLwITEwPair = unlines $
  [ "main"
  , "  = #input"
  , " -> if 1"
  , "     then"
  , "        {\"Hello, world!\", 0}"
  , "      else {\"Goodbye, world!\", 0}"
  ]

testMainwCLwITEwPair = unlines $
  [ "main"
  , "  = #input"
  , " -> if 1"
  , "     then"
  , "        {\"Hello, world!\", 0}"
  , "      else {\"Goodbye, world!\", 0}"
  ]

testMain3 = "main = 0"

test4 = "(#x -> if x then \"f\" else 0)"
test5 = "#x -> if x then \"f\" else 0"
test6 = "if x then \"1\" else 0"
test7 = unlines $
  [ "if x then \"1\""
  , "else 0"
  ]
test8 = "if x then 1 else 0"

runTestMainwCLwITEwPair = do
  preludeFile <- Strict.readFile "Prelude.sil"
  let
    prelude = case parsePrelude preludeFile of
      Right p -> p
      Left pe -> error . getErrorString $ pe
  case parseMain prelude testMainwCLwITEwPair of
    Right x -> return True
    Left err -> return False

testMain2 = "main : (#x -> if x then \"fail\" else 0) = 0"

runTestMainWType = do
  preludeFile <- Strict.readFile "Prelude.sil"
  let
    prelude = case parsePrelude preludeFile of
      Right p -> p
      Left pe -> error . getErrorString $ pe
  case parseMain prelude $ testMain2 of
    Right x -> return True
    Left err -> return False


testListAns = "TPair TZero (TPair (TPair TZero TZero) (TPair (TPair (TPair TZero TZero) TZero) TZero))"

testList0 = unlines $
  [ "[ 0"
  , ", 1"
  , ", 2"
  , "]"
  ]

testList1 = "[0,1,2]"

testList2 = "[ 0 , 1 , 2 ]"

testList3 = unlines $
  [ "[ 0 , 1"
  , ", 2 ]"
  ]

testList4 = unlines $
  [ "[ 0 , 1"
  , ",2 ]"
  ]

testList5 = unlines $
  [ "[ 0,"
  , "  1,"
  , "  2 ]"
  ]

-- |Usefull to see if tictactoe.sil was correctly parsed
-- and was usefull to compare with the deprecated SIL.Parser
-- Parsec implementation
testWtictactoe = do
  preludeFile <- Strict.readFile "Prelude.sil"
  tictactoe <- Strict.readFile "tictactoe.sil"
  let
    prelude = case parsePrelude preludeFile of
                Right p -> p
                Left pe -> error . getErrorString $ pe
  case parseMain prelude tictactoe of
    Right _ -> return True
    Left _ -> return False

-- -- |Helper function to debug tictactoe.sil
-- debugTictactoe :: IO ()
-- debugTictactoe  = do
--   preludeFile <- Strict.readFile "Prelude.sil"
--   tictactoe <- Strict.readFile "tictactoe.sil"
--   let prelude =
--         case parsePrelude preludeFile of
--           Right pf -> pf
--           Left pe -> error . getErrorString $ pe
--       p str = State.runStateT $ parseMain prelude str
--   case runParser (dbg "debug" p) "" tictactoe of
--     Right (a, s) -> do
--       putStrLn ("Result:      " ++ show a)
--       putStrLn ("Final state: " ++ show s)
--     Left err -> putStr (errorBundlePretty err)

runTictactoe = do
  preludeFile <- Strict.readFile "Prelude.sil"
  tictactoe <- Strict.readFile "tictactoe.sil"
  let
    prelude = case parsePrelude preludeFile of
      Right p -> p
      Left pe -> error . getErrorString $ pe
  case parseMain prelude $ tictactoe of
    Right x -> putStrLn $ show x
    Left err -> putStrLn . getErrorString $ err

testPair0ParsecResult = "TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero)))))))))))) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero)"

testITEParsecResult = "TITE (TPair TZero TZero) (TPair TZero TZero) (TPair (TPair TZero TZero) TZero)"

testITEWPairParsecResult = "TITE (TPair TZero TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero))))))))))))) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair (TPair TZero TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero) TZero))))))))))))))) (TPair TZero TZero))"

testParseAssignmentwCLwITEwPair1ParsecResult = "()"

