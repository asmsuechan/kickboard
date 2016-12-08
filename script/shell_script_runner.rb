require "open3"
class ShellScriptError < StandardError;end

# 何気なくscriptに置いたけどlibっぽい
module ShellScriptRunner
  # 各リポジトリを置くディレクトリ
  # ~/である意味は特にありません。
  REPOSITORY_ROOT = '~/'.freeze
  REPOSITORIES = Rails.application.repository.names

  class << self
    def pull(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git pull origin HEAD --rebase"
      exec(command)
      # エラー起きた時用にstash。エラー起きてない時は何も起こらない
      stash(repo_name)
    end

    def commit_and_push(repo_name, commit_message)
      pull(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git add . && git commit -m '#{commit_message}' && git push origin HEAD"
      exec(command)
      # エラー起きた時用にstash。エラー起きてない時は何も起こらない
      stash(repo_name)
    end

    def stash(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git stash"
      exec(command)
    end

    # destinationは該当リポジトリの絶対パス
    # TODO: 展開されたものをzipにするかその名前のフォルダをzipにするか
    # その名前のフォルダをzipにしたほうがやりやすい。
    def unzip_to_public(file_path, repo_name)
      destination = build_repo_path(repo_name)
      absolute_zip_path = Rails.root.join('tmp' + file_path).to_s
      command = "unzip " + absolute_zip_path + " -d " + destination + "/public"
      exec(command)
    end

    # gitのユーザー設定して各リポジトリをcloneしてpullするやつ。
    # ユーザー設定は別メソッドにする
    # TODO: githubアカウントどうするか
    # R/W権限あるユーザーでなければいけない
    # 指定したリポジトリを全て~/にcloneする
    # 配列でリポジトリ名を受け取る
    # rakeから実行するようにする
    def clone
      REPOSITORIES.each do |repo|
        # TODO: リポジトリ名からpullしてこれるようにするコードを書く。
        # 環境変数に他の部分入れておくとか
        repo_url = build_complete_repo_url(repo)
        command = "cd #{REPOSITORY_ROOT} && git clone #{repo_url}"
        exec(command)
      end
    end

    def build_complete_repo_url(repo_name)
      Rails.application.repository.base_url + repo_name + '.git'
    end

    def build_repo_path(repo_name)
      REPOSITORY_ROOT + repo_name
    end

    def exec(command)
      info, error, pid_and_exit_code = Open3.capture3(command)
      raise ShellScriptError, error unless pid_and_exit_code.success?
      #
      # pid_and_exit_code.class
      # => Process::Status
      # それぞれの変数には以下のような値が入ります。
      # info
      # [master a825daa] hoge
      #
      # error
      #  1 file changed, 2 insertions(+), 2 deletions(-)
      #  fatal: 'origin' does not appear to be a git repository
      #  fatal: Could not read from remote repository.
      #
      #  Please make sure you have the correct access rights
      #  and the repository exists.
      #
      # pid_and_exit_code
      #  pid 23122 exit 128
    end
  end
end
