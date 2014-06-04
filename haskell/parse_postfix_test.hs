import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
str = BC.pack "12 Jan 2014 03:10:00 [EWERWER234]"

main = do
	BC.putStrLn str
	print $ B.split str
	print $ B.head str
