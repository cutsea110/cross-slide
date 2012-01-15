---------------------------------------------------------
自己紹介

なまえ: 伊東勝利
しょぞく: 株式会社タイムインターメディア
すきなげんご: Haskell, Scheme
しゅみ: 水泳
とくぎ: バブルリング
twitter: @cutsea110

---------------------------------------------------------
Yesodとは
- Webフレームワーク
- Haskellで開発されている
-- 強い型付け
-- 純粋(side-effect free)
-- 速い
- ライブラリの集り
- フルスタック
-- Webサーバ
-- テンプレート
-- ORM
-- Add-on ライブラリ: auth,gravatar,jquery widget...
- YesodはFoundation

---------------------------------------------------------
Q1. 開発環境。コンパイラ、IDE、ライブラリ、など.
A1. 開発環境 GHC7/Linux.
    Yesodはそれ自体がライブラリの集りとなっています.
    IDEは特にありません. 
    個人的にはEmacs+haskell-mode+ghc-mod.

---------------------------------------------------------
Q2. メリット。こういうケースで長所が活きてくる。他にない技術、他より優れた方法.
A2. 

特長1. Type-safe URLs
- すべてのURLにはデータ型が対応
- パース,レンダリング,ハンドラ関数ディスパッチと自動的に同期

---------------------------------------------------------
(例)
mkYesod "MyApp" [parseRoutes|
/ RootR GET
/blog/#BlogId BlogPostR GET
/post/#Year/#Month/#Title
|]

---------------------------------------------------------
メリット(Type-safe URLs)
-- パスを1箇所に記述
-- 自動的にデータ型に対応付けされる
-- データ型の変更に対してコンパイラがエラーを捕捉

---------------------------------------------------------
特長2. Compile-time templates
- やさしい構文
- コンパイル時に検査される
- Haskellの変数を直接使える
-- テンプレート中に書くための糊付け用のコード不要
-- 自動的に型検査される
- シンプルな制御構文
- cssとjsもテンプレート

---------------------------------------------------------
(例) Hamlet(HTML)
!!!
<html>
  <head>
    <title>#{pageTitle} -My Site
    <link rel="stylesheet" href=@{StylesheetR}
  <body>
    <h1 .page-title>#{pageTitle}
    <p>おともだちの一覧:
    $if null friends
      <p>すまん. おともだちはいないや.
    $else
      <ul>
        $forall friend <- friends
          <li>#{fiendName friend} (#{show $ friendAge friend}才)
    <footer>^{copyright}

---------------------------------------------------------
(例) Lucius(CSS)
section.blog {
  padding: 1em;
  border: 1px solid #000;
  h1 {
    color: #{headingColor};
  }
  background-image: url(@{MyBackgroundR})
}

---------------------------------------------------------
(例) Julius(Javascript)
$(function(){
  $("section.#{sectionClass}").hide();
  $("#mybutton").click(function(){
    document.location = "@{SomeRouteR}";
    ^{addBling}
  });
})

---------------------------------------------------------
メリット(Compile-time templates)
- 簡単そうでしょ？
- ランタイムの表示エラーやリンク切れもない。
- 良く使うテンプレートも部品化して埋め込み可能
- XSS Protection

---------------------------------------------------------
(例) XSS Protection
name :: Text
name = "Michael <script>alert('XSS')</script>"
main :: IO ()
main = putStrLn $ renderHtml [shamlet|#{name}|]

出力:
Michael &lt;script&gt;alert(&#39;XSS&#39;)&lt;/script&gt;

---------------------------------------------------------
Persistent template&EDSL

- 1箇所でエンティティの宣言
- 自動的にHaskellの型やSQL用の関数と対応付け
- 各テーブルからIDを分離
- ライブラリで全ての対応付けと有効性検査がされる
- 自動マイグレーション
- SQLとMongoDBを容易に切り換え可能

---------------------------------------------------------
(例) Persistent template&EDSL
mkPersist [persist|
Person
  name Text
  age Int Maybe
BlogPost
  title Text
  author PersonId
|]

---------------------------------------------------------
(例) Persistent CRUD

runMigration migrateAll

johnId <- insert $ Person "John Doe" $ Just 35
janeId <- insert $ Person "Jane Doe" Nothing

insert $ BlogPost "My first post" johnId
insert $ BlogPost "One more for good measure" johnId

onePost <- selectList [BlogPostAutherId ==. JohnId] [LimitTo 1]
liftIO $ print (onePost :: [(BlogPostId, BlogPost)])

update johnId [PersonAge +=. Just 1]
john <- get johnId
liftIO $ print (john :: Maybe Person)

delete jothId
deleteWhere [BlogPostAutherId ==. johnId]

---------------------------------------------------------
メリット(Persistent template&EDSL)

- 簡単そうでしょ？
- クエリの記述がEDSLなのでプログラムでWhereなどを合成できる.

---------------------------------------------------------
メリット(速い)

- 実はよく知らないです.
- 古いけどsnoymanのベンチマーク.
-- www.yesodweb.com/blog/2011/03/preliminary-warp-cross-language-benchmarks

---------------------------------------------------------
Q3. デメリット。こういうケースでは使うべきじゃない.
A3. 

Windows Server上で開発する必要がある場合.
- GHC自体はWindows上でも動くがYesodは不明.

少なくとも現状ではMySQL,Oracle,SQL ServerなどはサポートしてないのでこれらのDBに縛りがある場合.


---------------------------------------------------------
Q4. 適用事例.
A4.

www.yesodweb.com - Yesod公式サイト
www.haskellers.com - Haskeller専用SNS
TKYProf - GHCプロファイラの可視化
Kestrel - WIKI(聖徳短期大学案件)
BISocie - BTS(聖徳短期大学案件)

その他: 
  www.yesodweb.com/wiki/powerd-by-yesodを参照ください.

---------------------------------------------------------
Q5. コミュニティの動向.
A5. 

- コミュニティの議論の場をweb-devel(HaskellのWeb一般)なMLからGoogle Group(Yesod Web Framework)に移行.
- 主にGoogle Groupで議論してYesodweb上のblogで技術の紹介やリリースアナウンスなどしている.
- 現在最新はYesod-0.9.4.1 (2011/12/27)で1〜6ヶ月おきに0.1ずつバージョンアップ.
- 実装技術(スタイル)的にはEnumeratorからConduitへシフト中.
- 1月あたりに予定されていたYesod-1.0(安定版)のリリースは見送り.
  Yesod-0.10でConduit化した後にあらためてというリスケジュールが発生. <= イマココ

---------------------------------------------------------
Q6. スライドで読める程度のコード(Hello Worldに毛が生えたくらい)
A6.

以下のどっちかを使う予定.

---------------------------------------------------------
本当に小さなのHelloに毛が生えたやつ.(non-db)

<<<
{-# LANGUAGE TypeFamilies, QuasiQuotes, MultiParamTypeClasses, TemplateHaskell, OverloadedStrings #-}

import Yesod

data Hello = Hello

mkYesod "Hello" [parseRoutes|
/             RootR  GET
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
>>>

---------------------------------------------------------
やはりDBがあった方が。(with-db)

<<<
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
|]

main :: IO ()
main = withSqlitePool ":memory:" 10 $ \pool -> do
  flip runSqlPool pool $ do
    runMigration migrateAll
    insert $ User "伊東 勝利" $ Just 41
    insert $ User "伊東 佳子" Nothing
    insert $ User "Michael Snoyman" $ Just 26
  warpDebug 3000 $ Hello pool
>>>

---------------------------------------------------------
Q7. 同じことをするWebアプリのコードから、言語・フレームワークの特徴を紹介する
A7

A6のHelloで説明するということでよろしいでしょうか.

1. アプリケーションがHelloというデータになっている.
2. YesodアプリにするのにYesodクラスのインスタンスにしている.
3. defaultLayoutでサイトのデフォルトページを設定できる.(Yesodクラスのメンバ)
4. selectList[][]だけでもUserテーブルをselectできてる.(型推論でクエリ対象テーブルを判断可能)
5. get404はIDでクエリして、あれば値をなければ404 Not Foundを返すといった高水準のAPIもある.
6. テンプレート中の@{UserR $ fst user}も型検査されている.
   (@{UserR user}などと間違っていればエラーになり,リンク切れのままリリースすることはできない.)
