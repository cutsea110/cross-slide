{-# LANGUAGE TypeFamilies, QuasiQuotes, MultiParamTypeClasses, TemplateHaskell, OverloadedStrings #-}
{-# LANGUAGE GADTs, FlexibleContexts #-}

import Yesod
import Database.Persist.Sqlite

data Hello = Hello ConnectionPool

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persist|
User
  name String
  age Int Maybe
|]

mkYesod "Hello" [parseRoutes|
/ RootR GET
/person/#UserId UserR GET
|]

instance Yesod Hello where
 approot _ = ""

instance YesodPersist Hello where
  type YesodPersistBackend Hello = SqlPersist
  runDB action = liftIOHandler $ do
    Hello pool <- getYesod
    runSqlPool action pool

getRootR :: Handler RepHtml
getRootR = do
  users <- runDB $ selectList [][]
  defaultLayout [whamlet|
<h1>ユーザ一覧
<ul>
  $forall user <- users
    <li>
      <a href=@{UserR $ fst user}>#{userName $ snd user}
|]

getUserR :: UserId -> Handler RepHtml
getUserR uid = do
  user <- runDB $ get404 uid
  defaultLayout [whamlet|
<h1>#{userName user}'s Page
<dl>
  <dt>なまえ
  <dd>#{userName user}
  <dt>ねんれい
  <dd>
    $maybe age <- userAge user
      #{show age}さい
    $nothing
      ヒ・ミ・ツ

<a href=@{RootR}>ホームへ
|]

main :: IO ()
main = withSqlitePool ":memory:" 10 $ \pool -> do
  flip runSqlPool pool $ do
    runMigration migrateAll
    insert $ User "伊東 勝利" $ Just 41
    insert $ User "伊東 佳子" Nothing
    insert $ User "Michael Snoyman" $ Just 26
  warpDebug 3000 $ Hello pool
