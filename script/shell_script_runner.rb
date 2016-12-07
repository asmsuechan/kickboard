require "open3"
class ShellScriptError < StandardError;end

module ShellScriptRunner
  class << self
    def pull(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git pull --rebase"
      exec(command)
    end

    def commit_and_push(repo_name, commit_message)
      pull(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git add . && git commit -m '#{commit_message}' && git push origin HEAD"
      exec(command)
    end

    # destinationは該当リポジトリの絶対パス
    # TODO: unzipで上書きされるかどうか。
    # TODO: 展開されたものをzipにするかその名前のフォルダをzipにするか
    # その名前のフォルダをzipにしたほうがやりやすい。
    def unzip_to_public(file_path, repo_name)
      destination = build_repo_path(repo_name)
      absolute_zip_path = Rails.root.join('tmp' + file_path).to_s
      shell_command = "unzip " + absolute_zip_path + " -d " + destination + "/public"
      exec(shell_command)
    end

    # gitのユーザー設定して各リポジトリをcloneしてpullするやつ。
    # TODO: githubアカウントどうするか
    # 指定したリポジトリを全て~/にcloneする
    def setup
    end

    def build_repo_path(repo_name)
      "~/" + repo_name
    end

    # ここでエラーハンドリングする
    def exec(command)
      info, error, pid_and_exit_code = Open3.capture3(command)
      # TODO: コマンド実行時のエラーログは別ファイルにする
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
