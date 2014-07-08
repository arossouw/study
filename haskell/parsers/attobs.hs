import Data.Attoparsec.Char8
import Data.ByteString.UTF8
import qualified Data.ByteString.Internal as S
import qualified Data.ByteString          as S (length, take, drop,readFile)
import qualified Data.ByteString.Char8 as Char8
import System.Environment
import qualified Data.ByteString.Lazy as BL
import Control.Applicative

data LogLine = LogLine {
       getMailq :: S.ByteString
} deriving (Ord, Show, Eq)

parseMailq :: Parser S.ByteString 
parseMailq = do 
	takeTill (== ']')
	anyChar
        anyChar
        q <- takeTill (== ':')
        return q

logFile :: FilePath
logFile = "log"


line :: Parser LogLine
line = do
     mq <- parseMailq
     return $ LogLine mq

-- s = "Jun 25 00:53:46 quire <info> postfix/qmgr[29155]: AE514ABE0FA4: from=<samanthawebster@nhs.net>, size=6705, nrcpt=3 (queue active)\nJun 25 00:53:44 quire <info> postfix/pipe[24809]: BCAB3ABE0F31: to=<engengraduate@fempower.co.za>, relay=kolabfilter, delay=1.2, delays=1.1/0/0/0.13, dsn=2.0.0, status=sent (delivered via kolabfilter service)\nJun 25 00:54:24 quire <info> postfix/qmgr[29155]: CA22EABE0FA4: from=<samanthawebster@nhs.net>, size=6702, nrcpt=3 (queue active)"


-- main =  S.readFile logFile >>= print . parseOnly line
--main = do
--     case parseOnly line s of
--        Left err -> putStrLn $ "parsing error found" ++ err
--        Right log -> mapM_ putStrLn log
             
 --    print . map parseOnly line . Char8.lines . file1
