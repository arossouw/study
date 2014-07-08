import Data.Char (toUpper)
import System.Environment

reverseWords :: String -> String
reverseWords = unwords . map reverse . words
-- main = do
--       interact $ show . reverseWords 

interactFile f fileName = do
   s <- readFile fileName
   putStr (f s)

main = do
    args <- getArgs
    mapM_ (interactFile (unlines . map reverseWords . lines)) args 
   

-- main = interact $ show . sum . map read . lines
