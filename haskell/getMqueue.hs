import System.IO 
import Data.List
import Data.List.Split
import qualified Data.Text as T

main :: IO ()
main = do
	inh <- openFile "postfix.log.95" ReadMode
	outh <- openFile "t" WriteMode
	inpstr <- hGetContents inh
	let result = test inpstr
	hPutStr outh result
	hClose inh
	hClose outh

-- getMq :: String -> [[String]]
-- getMq = splitOn ": " . unwords . tail . splitOn "]: "

-- test :: String -> [[String]]
-- test = unwords . map getMq . lines 

getMq :: String -> String
-- getMq = unlines . unwords . head . splitOn ": " . unwords . tail . splitOn "]: "
getMq = T.head . splitOn ": " . T.unwords . T.tail . splitOn "]: "

test :: String -> String
test = T.unwords . T.map getMq . T.lines . T.strip $ T.pack
