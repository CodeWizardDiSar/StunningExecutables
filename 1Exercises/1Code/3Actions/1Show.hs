{-# LANGUAGE LambdaCase,TypeSynonymInstances,FlexibleInstances #-} 
module Show where
import Prelude hiding (all)
import Control.Arrow
import Data.Function
import Renaming
import Useful
import Types
import FcsToExs 
import Messages
import ActionMessages

s :: SHO a => a->STR
s = sho
fill = \i s->take i$s++repeat ' '
f15  = fill 15
mf15 = map f15

instance SHO EXR where
  sho =
    \case Don (n,nu,e)   ->[n,nu,s e]     &(mf15>>>cnc)
          Mis (n,nu,e)   ->[n,nu,s e]     &(mf15>>>cnc)
          Tdo (n,nu,e) da->[n,nu,s e,s da]&(mf15>>>cnc)

instance SHO EXS where sho = map (sho>>>tabBefore>>>(++"\n"))>>>cnc 
instance SHO HEN where sho = \case Nng->"No Name";Idd e->e 
instance SHO DAT where sho = \(d,m,y)->cnc [sho d,"/",sho m,"/",sho y]
instance SHO INT where sho = cts

pri=sho>>>printString
isDone   = \case (Don ed)  ->True;_->False
isMissed = \case (Mis ed)  ->True;_->False
isToDo   = \case (Tdo ed d)->True;_->False

filterAndPrint = \f->exs>>=(filter f>>>pri)
showToDo   = filterAndPrint isToDo
showDone   = filterAndPrint isDone
showMissed = filterAndPrint isMissed
showAll    = exs>>=pri