hello :: String -> IO ()
hello str = putStrLn ("Hello" ++ str)

nextNum :: Int -> IO Int
nextNum i = do
      putStrLn ("successor of " ++ show i)
      return (succ i)

encrypt :: String -> String
encrypt a = map succ a

main = do
    -- input <- getLine
    -- putStrLn (encrypt input)
    sequence ["Hello","World"]
    mapM_ print sequence
     --  sequence [getLine,getLine]
     -- mapM_ print sequence
