# README


# How to use
セットアップに必要なこと

* git configでコミット権持ったユーザーをサーバーに追加する
* サーバーの~/以下にKickboardで使いたいリポジトリをclone
* config/repository.yml にリポジトリのフォルダ名を追加
* もしREPOSITORY_ROOTを変更したい場合は `export REPOSITORY_ROOT=<設定したいパス>のようにしてください
* zipを作った場合はこのアプリケーションのpublic以下にzipが配置されます
* rollbackを使えるのはadmin権限を持つユーザーのみです。adminユーザーを使用するには/?admin=aaaaaaaaのようなパラメーターをつけてアクセスしてください
