import qualified Data.ByteString as BS
import Data.Attoparsec.ByteString.Char8
import Control.Applicative
import Data.List

parser = many (decimal <* char '\n')

reallyParse p bs = case parse p bs of
    Partial f -> f BS.empty
    v -> v

main = do
    numbers <- BS.readFile "postfix.log.95"
    case reallyParse parser numbers of
        Done t r | BS.null t -> writeFile "sorted" . unlines . map show . sort $ r
