{-# LANGUAGE OverloadedStrings #-}
import Data.Attoparsec.Char8
import Data.ByteString.UTF8
import qualified Data.ByteString.Internal as S
import qualified Data.ByteString          as S (length, take, drop,readFile)
import qualified Data.ByteString.Char8 as Char8
import System.Environment
import qualified Data.ByteString.Lazy as BL
import Data.List as D

data LogLine = LogLine {
       getMailq :: S.ByteString
} deriving (Ord, Show, Eq)

parseMailq :: Parser S.ByteString 
parseMailq = do 
	takeTill (== ']')
	anyChar
        anyChar
	anyChar
        q <- takeTill (== ':')
        return q

line :: Parser LogLine
line = do
     mq <- parseMailq
     return $ LogLine mq

oneline = Char8.pack("Jun 25 00:53:46 quire <info> postfix/qmgr[29155]: AE514ABE0FA4: from=<samanthawebster@nhs.net>, size=6705, nrcpt=3 (queue active)")

s = Char8.pack("Jun 25 00:53:46 quire <info> postfix/qmgr[29155]: AE514ABE0FA4: from=<samanthawebster@nhs.net>, size=6705, nrcpt=3 (queue active)\nJun 25 00:53:44 quire <info> postfix/pipe[24809]: BCAB3ABE0F31: to=<engengraduate@fempower.co.za>, relay=kolabfilter, delay=1.2, delays=1.1/0/0/0.13, dsn=2.0.0, status=sent (delivered via kolabfilter service)\nJun 25 00:54:24 quire <info> postfix/qmgr[29155]: CA22EABE0FA4: from=<samanthawebster@nhs.net>, size=6702, nrcpt=3 (queue active)")

test = Char8.lines s
linetest = case parseOnly line oneline of
           Left err -> print err
           Right res -> print res

linetest2  x = case parseOnly line x of
           Left err -> show err
           Right res -> show res
test2 y = case parseOnly line y of
           Left err -> show (err)
           Right res -> show (res)

-- main :: IO ()
-- main = linetest
-- main :: IO ()
main = print ( map (linetest2) (Char8.lines(s)))

-- processIt x = D.map (parse parseMailq) x
--func x = case BL.parse line x of
--         Left err -> print err
 --        Right res -> print res
--	-- omapM_  parse line test
--	let r = do x <- parseOnly line test
--		return $ test
--        case r of
--          Left err -> putStrLn $ "An error " ++ err
--          Right log -> mapM_ print log
