-- source http://stackoverflow.com/questions/4064532/using-parsec-with-data-text
module TestText where

import Data.Text as T

import Text.Parsec
import Text.Parsec.Prim
import Text.Parsec.Text

input = T.pack "xxxxxxxxxxxxxxyyyyxxxxxxxxxp"

parser = do
  x1 <- many1 (char 'x')
  y <- many1 (char 'y')
  x2 <- many1 (char 'x')
  return (T.pack x1, T.pack y, T.pack x2)

test = runParser parser () "test" input
