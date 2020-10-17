{-# LANGUAGE TemplateHaskell #-}
module CS30.Exercises.Cardinality (cardEx) where
import           CS30.Data
import           CS30.Exercises.Data
import           Data.List.Extra (nubSort)
import qualified Data.Map as Map
import           Data.Aeson.TH
import Debug.Trace


data CardExp = CardExp deriving Show
-- type CardExp a = ([Field],a)
-- $(deriveJSON defaultOptions ''CardExp)

cardEx :: ExerciseType

cardEx = exerciseType "Cardinality" "L??" "Cardinality of Expression" 
            cardinality
            cardQuer 
            cardFeedback

allCards :: [Int]
allCards = [1..99]

cardinality :: [ChoiceTree ([[Field]], [String])]
cardinality = [ 
            -- cardinality of a power set
            nodes [ ( [[FText"|A| ", FMath$ "= "++d1], [FText "|𝒫",FMath$ "(A)", FText"|"]]
                     , ["2^"++d1] -- needs {}
                     )
                   | d1 <- map show allCards]
            -- cardinality of the cartesian product of two sets
           , nodes [ ( [[FText"|A| ", FMath$ "= "++d1, FText" and |B| ", FMath$"= "++d2], 
                        [FText"|", FMath$ "A x B", FText"|"]]
                     , [show (read (d1) * read(d2))] -- this actually does out the mulitplication (but idk if we necessarily want them to, smthg to think about)
                     )
                   | d1 <- map show allCards, d2 <- map show allCards]
            -- cardinality of set x its powerset
           , Branch [ nodes [ ( [[FText"|A| ", FMath$"= "++d1],
                                [FText"|", FMath$"A x ", FText"𝒫", FMath"(A)", FText"|"]]
                              ,[d1++"*2^"++d1, -- needs \\cdot and {}
                                "2^"++d1++"*"++d1] -- needs \\cdot and {}
                              )
                            | d1 <- map show allCards]
                     ] 
            -- cardinality with set builder notatino (like ex from the assignment sheet)
           , Branch [ nodes [ ( [[FText"|B| ", FMath$ "= "++d2],
                                 [FText"|", FMath$"\\left\\{A | A \\subseteq B, |A| ="++d1++"\\right\\}", FText"|"]]
                              , [d2++" choose "++ d1]
                              )
                            | d1 <- map show allCards, d2 <- map show allCards]
                    ]
           ]


cardQuer :: ([[Field]],[String]) -> Exercise -> Exercise
cardQuer (quer, _solution) exer 
  = trace("solution " ++  show _solution) -- for testing 
    exer { eQuestion=[FText "Given "] ++ rule ++ 
                     [FText ", compute "] ++ question ++ 
                     [FFieldMath "answer"]}
                        where rule = head quer
                              question = quer!!1

-- rosterQuer :: ([Field],a) -> Exercise -> Exercise
-- rosterQuer (quer, _solution) def 
--  = def{ eQuestion = [ FText $"Write "] ++quer++
--                     [ FText " in roster notation", FFieldMath "roster" ] }


-- cardFeedback :: CardExp -> Map.Map String String -> ProblemResponse -> ProblemResponse
cardFeedback _ mStrs rsp 
  =  trace ("gen feedback " ++ show mStrs) $ -- for testing
      case Map.lookup "answer" mStrs of 
       Just v -> markCorrect $ 
                 rsp{prFeedback = [FText("you entered " ++ show v)]}
       Nothing -> error "Answer field expected"


-- rosterFeedback :: ([Field], [String]) -> Map.Map String String -> ProblemResponse -> ProblemResponse
-- rosterFeedback (quer, sol) usr' defaultRsp
--   = reTime$ case pr of
--                  Nothing -> wrong{prFeedback= rsp++(FText "Your answer was "):rspwa}
--                  Just v -> if nub v == v then
--                               (if Set.fromList v == Set.fromList sol then correct{prFeedback=rsp}
--                                else wrong{prFeedback=rsp++[FText$ ". You answered a different set: "]++rspwa})
--                            else wrong{prFeedback=rsp++[FText ". Your answer contained duplicate elements: "]++rspwa}
--   where solTeX = dispSet sol
--         usr = Map.lookup "roster" usr'
--         pr :: Maybe [String]
--         pr = case usr of
--                Nothing -> Nothing
--                Just v -> case getSet (Text.pack v) of
--                            Left _ -> Nothing -- error (errorBundlePretty str)
--                            Right st -> Just (map Text.unpack st)
--         rsp = [FText $ "In roster notation, "]++quer++[FText " is ", FMath solTeX]
--         rspwa = case usr of
--                 Nothing -> [FText "- ??? - (perhaps report this as a bug?)"]
--                 Just v -> [FMath v]
--         wrong = markWrong defaultRsp
--         correct = markCorrect defaultRsp

