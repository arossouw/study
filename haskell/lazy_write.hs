import Data.Monoid
import qualified Data.ByteString.Lazy as L
import Blaze.ByteString.Builder as B
import Blaze.ByteString.Builder.Char.Utf8

strings :: [String]
strings = replicate 10000 "Hello World!"

concatenation :: Builder
concatenation = mconcat $ map fromString strings

result :: L.ByteString
result = toLazyByteString concatenation

main = L.writeFile "E" result
