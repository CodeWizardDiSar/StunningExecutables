module Edit where
import Prelude
  ((.), not, filter, (-), (!!), (==), getLine, (++), (>>=), IO, String, Int)
import Add
  (getDate)
import UsefulForActions
  (combine, askAndGetAnswer, writeExercisesToFile, getSubjects)
import Renaming 
  (printString, wrap, andThen, (>>>), append)
import ExercisesFromFile
  (getToDoExercises, getDoneExercises, getMissedExercises)
import Data.Function
  ((&))
import FileManagement
  (updateVersion)
import Types
  (Exercise(..), HopefullySome(..), Exercises)
import UsefulFunctions
  (printStrings)
import ShowExercises
  (getChosen, subIs)
import Control.Monad
  ((>=>))
import Choices
  (numbered)

-- edit list of actions
editActions :: [ IO () ]
editActions = [edit "todo", edit "done", edit "missed"]

edit :: String -> IO ()
edit = getAllExs >=> writeExercisesToFile >=> \_ -> updateVersion

getAllExs :: String -> IO Exercises
getAllExs = \case
 "todo" ->
   combine [getToDoExercises >>= getAndEditChosen, getDoneExercises, getMissedExercises]
 "done" ->
   combine [getToDoExercises, getDoneExercises >>= getAndEditChosen, getMissedExercises]
 "missed" ->
   combine [getToDoExercises, getDoneExercises, getMissedExercises >>= getAndEditChosen]

getAndEditChosen :: Exercises -> IO Exercises
getAndEditChosen = getChosen >=> editChosen

editChosen :: (Exercises,Int,Int) -> IO Exercises
editChosen = \(exs,subNum,exNum)->
 let sub=getSubjects exs!!(subNum-1)
     ex=filter (subIs sub) exs!!(exNum-1)
 in modify ex>>=((:filter (not.(==ex)) exs)>>>wrap)

modify = \case
  ToDo (s, eNum, eName) d ->
    chooseAttributeWithDate >>= \case
      "1"-> getSubject >>= \newSub ->
        ToDo (newSub, eNum, eName) d & wrap
      "2"-> getENum >>= \newENum ->
        ToDo (s, newENum, eName) d & wrap
      "3"-> getEName >>= \newEName->
        ToDo (s, eNum, IndeedItIs newEName) d & wrap
      "4"-> getDate >>= \newDate ->
        ToDo (s, eNum, eName) newDate & wrap
  Done (s,eNum,eName) ->
    chooseAttribute >>= \case
      "1"->getSubject >>= \newSub ->
        Done (newSub, eNum, eName) & wrap
      "2"->getENum >>= \newENum ->
        Done (s, newENum, eName) & wrap
      "3"->getEName >>= \newEName->Done (s,eNum,
                                                IndeedItIs
                                                newEName)&wrap
  Missed (s,eNum,eName)   ->
    chooseAttribute>>= \case
      "1"->getSubject>>= \newSub  ->Missed (newSub,eNum,
                                                    eName)&wrap
      "2"->getENum   >>= \newENum ->Missed (s,newENum,
                                                    eName)&wrap
      "3"->getEName  >>= \newEName->Missed (s,eNum,
                                                 IndeedItIs
                                                 newEName)&wrap

chooseAttribute         = printBasic`andThen`getLine
chooseAttributeWithDate = printBasicAndDate`andThen` getLine

exData = [ "Subject", "Exercise Number", "Exercise Name" ]
printBasic = exData&numbered&printStrings
printBasicAndDate = exData++["Date"]&numbered &printStrings

getSubject = askAndGetAnswer "New Subject?"
getENum    = askAndGetAnswer "New Exercise Number?"
getEName   = askAndGetAnswer "New Exercise Name?"
