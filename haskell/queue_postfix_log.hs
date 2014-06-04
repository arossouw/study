import qualified  Data.ByteString.Lazy as L
import qualified Data.ByteString.Char8 as W
import Blaze.ByteString.Builder
import Blaze.ByteString.Builder.Char.Utf8

concatenation :: Builder
concatenation x = mconcat $ map fromString x

result :: L.ByteString
result y = toLazyByteString concatenation y

main = do
  contents <- L.readFile "postfix.log.95"
  -- L.writeFile "b" contents
  -- L.writeFile "b" result

  print $ L.unpack (L.head contents)
