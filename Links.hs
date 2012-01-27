{-# LANGUAGE TypeFamilies, QuasiQuotes, MultiParamTypeClasses, TemplateHaskell, OverloadedStrings #-}
{-# LANGUAGE GADTs, FlexibleContexts #-}

import Yesod
import Database.Persist.Sqlite
import Data.Text (Text)
import Control.Applicative ((<$>),(<*>))

data Links = Links ConnectionPool

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persist|
Link
  title Text
  url Text
|]

mkYesod "Links" [parseRoutes|
/ RootR GET
/add-link AddLinkR POST
|]

instance Yesod Links where
 approot _ = ""
 
instance RenderMessage Links FormMessage where
  renderMessage _ _ = defaultFormMessage

instance YesodPersist Links where
  type YesodPersistBackend Links = SqlPersist
  runDB action = do
    Links pool <- getYesod
    liftIOHandler $ runSqlPool action pool

getRootR :: Handler RepHtml
getRootR = defaultLayout $ do
  toWidget [lucius|.message{color:red;}|]
  [whamlet|
<form method=post action=@{AddLinkR}>
  <p>
    URL #
    <input type=url name=url value=http://>
    \ タイトル #
    <input type=text name=title>
    \ #
    <input type=submit value=リンクを追加する>
<h2>登録済みのリンク
^{existingLinks}
|]

existingLinks :: Widget
existingLinks = do
  links <- lift $ runDB $ selectList [] []
  toWidget [lucius|li{list-style-type:none;}|]
  [whamlet|
<ul>
  $forall link <- links
    <li>
      <a href=#{linkUrl $ snd link}>#{linkTitle $ snd link}
|]

postAddLinkR :: Handler ()
postAddLinkR = do
  link <- runInputPost $ Link 
               <$> ireq textField "title"
               <*> ireq urlField "url"
  runDB $ insert link
  setMessage "リンクを追加しました."
  redirect RedirectSeeOther RootR

main :: IO ()
main = withSqlitePool ":memory:" 10 $ \pool -> do
  flip runSqlPool pool $ do
    runMigration migrateAll
  warpDebug 3000 $ Links pool
