{-# LANGUAGE TypeFamilies, QuasiQuotes, MultiParamTypeClasses, TemplateHaskell, OverloadedStrings #-}

import Yesod

data Hello = Hello

mkYesod "Hello" [parseRoutes|
/             RootR GET
/user/#String UserR GET
|]

instance Yesod Hello where
 approot _ = ""

getRootR :: Handler RepHtml
getRootR = do 
  let names = words "かつとし けいこ Michael"
  defaultLayout [whamlet|
<h1>Hello World!
<ul>
  $forall name <- names
    <li>
      <a href=@{UserR name}>#{name}
|]

getUserR :: String -> Handler RepHtml
getUserR name = defaultLayout [whamlet|
<h1>#{name}'s Page
<h2>#{name}の紹介
<a href=@{RootR}>ホームへ
|]

main :: IO ()
main = warpDebug 3000 Hello
