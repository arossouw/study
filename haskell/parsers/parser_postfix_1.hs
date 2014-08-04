{-# LANGUAGE OverloadedStrings #-}
import Data.Attoparsec.Char8
import Data.ByteString.UTF8
import qualified Data.ByteString.Internal as S
import qualified Data.ByteString          as S (length, take, drop,readFile, pack)
import qualified Data.ByteString.Char8 as Char8
import System.Environment
import qualified Data.ByteString.Lazy as BL
import Data.List as D

data LogLine = LogLine {
       getMailq :: S.ByteString
} deriving (Ord, Show, Eq)

parseMailq :: Parser Char8.ByteString 
parseMailq = do 
	takeTill (== ']')
	anyChar
        anyChar
	anyChar
        q <- takeTill (== ':')
	return q

parseSender :: Parser Char8.ByteString
parseSender = do
      takeTill (== ']')
      takeTill (== '<')
      anyChar
      sender <- takeTill (== '>')
      return sender

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

linetest2 x = case parseOnly parseMailq x of
           Left err -> show (err)
           Right res -> show (res)

linetest3 x = case parseOnly parseSender x of
           Left err -> show err 
           Right res -> show res 

stripChars :: String -> String -> String
stripChars = filter . flip notElem


main :: IO ()
main = do
      contents <- Char8.getContents
      print $ map linetest2 (Char8.lines(contents))
-- main = print ( map (linetest2) (Char8.lines(s)))
--main = do
--       let y = map linetest2 (Char8.lines(s))
--       let stripped = map (stripChars "\"") y
--       print stripped
