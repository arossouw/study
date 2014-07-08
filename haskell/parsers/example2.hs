import System.Cmd
import Data.Attoparsec.Char8
import qualified Data.ByteString.Char8 as Char8
import System.IO
import System.Exit
import Data.ByteString.UTF8
import qualified Data.ByteString.Internal as S
import qualified Data.ByteString          as S (length, take, drop)
import Data.List

data SocksLine = SocksLine {
  getHost :: S.ByteString,
  getPort :: S.ByteString
} deriving (Ord, Show, Eq)

colon :: Parser Char
colon = satisfy (== ':')
