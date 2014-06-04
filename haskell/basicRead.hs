import System.Environment
main = do
  s <- getContents
  let r = map processIt (lines s)
  putStr (unlines r)


processIt s = show (s)
