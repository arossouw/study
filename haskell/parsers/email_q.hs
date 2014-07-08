{-# LANGUAGE OverloadedStrings #-}
import Text.ParserCombinators.Parsec
import Text.Parsec.String
import System.Exit
import System.Environment

interactFile f fileName = do
   s <- readFile fileName
   putStr (f s)


data LogLine = LogLine {
       getMailq :: String
} deriving (Ord, Show, Eq)

plainval :: Parser String
plainval = many1 (noneOf "\n")

noSpace :: Parser String 
noSpace = many1 (noneOf " ")

logLine :: Parser LogLine 
logLine = do
      month <- noSpace
      space
      day <- noSpace
      space 
      time <- noSpace
      space 
      host <- noSpace
      space 
      logLevel <- noSpace
      space
      smtpq <- noSpace
      space
      mailq <- noSpace
      space
      rcpt_or_sender <- noSpace
      -- return $ LogLine (month ++ " " ++ day ++ " " ++ time) mailq rcpt_or_sender
      return $ LogLine mailq 
      -- show (mailq)



testLine = "Jun 25 00:24:16 quire <info> postfix/qmgr[29155]: 354E7ABE0FA4: from=<brigittem@mweb.co.za>, size=692038, nrcpt=2 (queue active)\n"
-- main = case parse logLine "(test)" testLine of
--	Left err -> print err
--	Right res -> print res
-- main :: IO ()
-- io f = interact (unlines . f . lines)

-- main = io (map (parse "(test)") logLine)
 --   file <- readFile "pfix.log"
 --   let logLines = lines file
 --   result <- mapM_ (parse "(test)") logLine
parse' :: Parser a -> String -> IO a
parse' p fileName = parseFromFile p fileName >>= either report return
       where 
          report err = do
              putStrLn $ "Error: " ++ show err
              exitFailure     

-- main = interact $ show . parse logLine . map read . lines
-- main = 
--   do
--     args <- getArgs
--     mapM_ (interactFile (unlines . parse logLine . lines)) args
