require "open3"
module ShellScriptRunner
  class << self
  def pull(repo_name)
    command = "cd #{build_repo_path(repo_name)} && git pull --rebase"
    exec(command)
  end

  def commit_and_push(repo_name)
    pull(repo_name)
    command = "cd #{build_repo_path(repo_name)} && git add . && git commit -m 'hoge' && git push origin HEAD"
    exec(command)
    #
    # クラス化してgit pushまでするメソッドとgitエラー時のメソッドとzipを展開するメソッドに分けたほうがいい
  end

  # destinationは該当リポジトリの絶対パス
  def unzip_to_public(file_path, repo_name)
    destination = build_repo_path(repo_name)
    # TODO: ここもメソッド化する?
    absolute_zip_path = Rails.root.join('tmp' + file_path).to_s
    shell_command = "unzip " + absolute_zip_path + " -d " + destination + "/public"
    exec(shell_command)
  end

  # gitのユーザー設定して各リポジトリをcloneしてpullするやつ。
  def setup
  end

  def build_repo_path(repo_name)
    "~/" + repo_name
  end

  # ここでエラーハンドリングする
  def exec(command)
    info, error, pid_and_exit_code = Open3.capture3(command)
    puts "====="
    puts command
    puts "====="
    puts info
    puts error
    puts pid_and_exit_code
    # それぞれ
    # commit_info
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
