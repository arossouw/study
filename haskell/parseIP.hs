{-# LANGUAGE OverloadedStrings #-}
import Data.Attoparsec.ByteString.Char8
import Data.Word

data IP = IP Word8 Word8 Word8 Word8 deriving Show

parseIP :: Parser IP
parseIP = do
    d1 <- decimal
    char '.'
    d2 <- decimal
    char '.'
    d3 <- decimal
    char '.'
    d4 <- decimal
    return $ IP d1 d2 d3 d4

main :: IO ()
main = print $ parseOnly parseIP "128.22.33.131"
