import Data.List
import System.Environment

interactFile f fileName = do
   s <- readFile fileName
   putStr (f s)

main =
    do
      args <- getArgs
      -- filter (isInfixOf "samanth") . (lines  args )
      mapM_ (interactFile (unlines . filter (isInfixOf "samantha") . lines)) args
