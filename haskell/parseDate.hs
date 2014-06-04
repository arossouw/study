import Data.Time
import Data.Attoparsec.Char8
import qualified Data.ByteString.Char8 as BC


data Procut = Mouse | Keyboard | Monitor | Speakers

data LogEntry = 
	LogEntry {
		  entryTime :: LocalTime
		 } deriving Show

type Log = [LogEntry]
bs = BC.pack "2013-06-30 14:33:29"

timeParser :: Parser LocalTime
timeParser = do
      y <- count 4 digit
      char '-'
      mm <- count 2 digit
      char '-'
      d <- count 2 digit
      char ' '
      h <- count 2 digit
      char ':'
      m <- count 2 digit
      char ':'
      s <- count 2 digit
      return $
	 LocalTime { localDay = fromGregorian (read y) (read mm) (read d)
		    , localTimeOfDay = TimeOfDay (read h) (read m) (read s)
		   }

main :: IO ()
main = print $ parseOnly timeParser bs
