-- from stackoverflow, read large csv file

import qualified Data.ByteString.Lazy.Char8 as L
import Control.Parallel.Strategies
import GHC.Conc(numCapabilities)

processContents :: L.ByteString -> L.ByteString
processContents contents = L.unlines (out `using` parListChunk chunks rdeepseq)
    where ls  = zip [1..] (L.lines contents)
          out = map (\(n,l) -> l `L.append` sep `L.append` L.pack (show n)) ls
          sep = L.pack ";"
          chunks = 1 + (length ls `div` numCapabilities)

main = do
    contents <- L.readFile "myfile.csv"
    L.putStr (processContents contents)
