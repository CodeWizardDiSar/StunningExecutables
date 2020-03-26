module FileManagement where
import Renaming         (checkThat,fileExists,printString,
                         readFromFile,writeToFile,
                         unwrapAnd,andThen,wrap,and,append,
                         unwrapped,convertIntFromString,
                         convertIntToString)
import UsefulFunctions  (addOneToString,subOneFromString)
import Prelude          (IO,String,FilePath,Bool(..),(+),flip)
import System.Directory (renameFile)
import Data.Function    ((&))
import Control.Monad    ((>=>))

-- Paths
homeDir           = "/home/gnostis"
desktopDir        = homeDir     `append`"/Desktop"
exercisesDir      = desktopDir  `append`
                    "/3StunningExecutables/1Exercises"
dataDir           = exercisesDir`append`"/2Data"
versionKeeper     = dataDir     `append`"/ver"   
tempVersionKeeper = dataDir     `append`"/verTmp"
dataKeeperPrefix  = dataDir     `append`"/data"  

-- Get, Update and Downdate verion
getVersion =
 checkThat (versionKeeper&fileExists)`unwrapAnd`\case
  True-> readFromFile versionKeeper                    
  _   -> writeToFile versionKeeper "0"`andThen`wrap "0"
updateVersion =
 getVersion`unwrapAnd`(addOneToString`and`writeToTemp)`andThen`
 renameTemp
downdateVersion =
 getVersion`unwrapAnd`\case
  "0"-> printString "Who you kidding brother?"
  s  -> (subOneFromString`and`writeToTemp) s`andThen`renameTemp
writeToTemp = writeToFile tempVersionKeeper
renameTemp = renameFile tempVersionKeeper versionKeeper

-- Get Current and Next Data Keeper + Write to Next
getCurrentDataKeeper =
 getVersion`unwrapAnd`(addDKPrefix`and`wrap)
getNextDataKeeper =
 getVersion`unwrapAnd`(addOneToString`and`addDKPrefix`and`wrap)
writeToNextDataKeeper = \s->
 getNextDataKeeper`unwrapAnd`flip writeToFile s
addDKPrefix = (dataKeeperPrefix`append`)
