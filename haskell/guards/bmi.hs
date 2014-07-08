bmiTell :: (RealFloat a) => a -> String
bmiTell bmi
    | bmi <= 18.5 = "You're underweight , you emo, you!"
    | bmi <= 25.0 = "You're supposedly normal. Pfft , I bet you're ugly!"
    | bmi <= 30.0 = "You're fat! Lose some weight, fatty!"
    | otherwise = "You're a while , congratulations!"

bmiT :: (RealFloat a) => a -> a -> String
bmiT weight height
    | weight / height ^ 2 <= 18.5 = "You're underweight, you emo!"
    | weight / height ^ 2 <= 25.0 = "You're supposedly normal. I bet you're ugly!"
    | weight / height ^ 2 <= 30.0 = "You're fat! Lose some weight, fatty!"
    | otherwise			  = "You're a whale,congrats!"

bmiShow :: (RealFloat a) => a -> a -> String
bmiShow weight height
    | bmi <= 18.5 = "You're underweight , you emo, you!"
    | bmi <= 25.0 = "You're supposedly normal. Pfft , I bet you're ugly!"
    | bmi <= 30.0 = "You're fat! Lose some weight, fatty!"
    | otherwise = "You're a while , congratulations!"
    where bmi = weight / height ^ 2

bmiS :: (RealFloat a) => a -> a -> String    
bmiS weight height
    | bmi <= skinny = "You're underweight, you emo!"
    | bmi <= normal = "You're supposedly normal. I bet you're ugly!"
    | bmi <= fat    = "You're a whale, congrats!"
    where bmi = weight / height ^ 2
    	  (skinny, normal, fat) = (18.5, 25.0, 30.0)

calcBmis :: (RealFloat a) => [(a,a)] -> [a]
calcBmis xs = [bmi w h | (w, h) <- xs]
     where bmi weight height = weight / height ^ 2

main :: IO ()
-- main = (print . bmiTell) 100
-- main = (print . bmiT 85) 1.90
-- main = (print . bmiShow 85) 1.90
main = (print . bmiS 85) 1.90
