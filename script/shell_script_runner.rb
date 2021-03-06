require "open3"
require "pry-byebug"
require "securerandom"
class ShellScriptError < StandardError;end
class RollbackError < StandardError;end

# 何気なくscriptに置いたけどlibっぽい
module ShellScriptRunner
  # 各リポジトリを置くディレクトリ
  # ~/である意味は特にありません。
  REPOSITORY_ROOT = "#{ENV['REPOSITORY_ROOT'] || ENV['HOME']}/".freeze
  SETTING_PATH = "#{Rails.root}/config/repository.yml".freeze
  REPOSITORIES = YAML.load_file(SETTING_PATH)['names'].freeze
  BRANCHES = YAML.load_file(SETTING_PATH)['branches'].freeze
  REPOSITORY_BASE_URL = YAML.load_file(SETTING_PATH)['base_url'].freeze
  DEFAULT_COMMIT_MESSAGE = "[auto commit from kickboard]"

  class << self
    def pull(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git pull origin HEAD --rebase"
      exec(command)
      # エラー起きた時用にstash。エラー起きてない時は何も起こらない
      stash(repo_name)
    end

    def commit_and_push(repo_name, commit_message)
      command = "cd #{build_repo_path(repo_name)} && git add . && git commit -m '#{commit_message}' && git push origin HEAD"
      exec(command)
      # エラー起きた時用にstash。エラー起きてない時は何も起こらない
      stash(repo_name)
    end

    def stash(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git stash"
      exec(command)
    end

    def unzip_to_public(file_path, repo_name)
      # destinationは該当リポジトリ(展開先)の絶対パス
      destination = build_repo_path(repo_name)
      absolute_zip_path = Rails.root.join('tmp' + file_path).to_s
      command = "unzip -o " + absolute_zip_path + " -d " + destination + "/public"
      exec(command)
    end

    # gitのユーザー設定して各リポジトリをcloneしてpullするやつ。
    # ユーザー設定は別メソッドにする
    # TODO: githubアカウントどうするか
    # R/W権限あるユーザーでなければいけない
    # 指定したリポジトリを全て~/にcloneする
    def clone
      REPOSITORIES.each_with_index do |repo, i|
        repo_url = build_complete_repo_url(repo)
        branch_name = BRANCHES[i]
        command = "cd #{REPOSITORY_ROOT} && git checkout #{branch_name} && git clone #{repo_url}"
        exec(command)
      end
    end

    # 操作ミス用にgit reset --hard HEAD^してforce-pushでます。
    # 最新コミットがkickboardからのものでない時はrollbackできないようにしている
    def rollback(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git reset --hard HEAD^ && git push -f origin HEAD"
      if latest_commit_log(repo_name).include?(DEFAULT_COMMIT_MESSAGE)
        exec(command)
      else
        raise RollbackError.new('最新コミットがKickboardからのコミットではありません。')
      end
    end

    def latest_commit_log(repo_name)
      logs(repo_name)[1]
    end

    def logs(repo_name)
      command = "cd #{build_repo_path(repo_name)} && git log"
      exec(command, stdout: true).split("\n\n")
    end

    def build_complete_repo_url(repo_name)
      REPOSITORY_BASE_URL + repo_name + '.git'
    end

    def build_repo_path(repo_name)
      REPOSITORY_ROOT + repo_name
    end

    def tree_public
      command = "cd #{build_repo_path(repo_name)} && pwd;find ./public | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'"
    end

    def branch_has_been_set_by_yml(repo_name)
      branch_name = BRANCHES[REPOSITORIES.index(repo_name)]
    end

    def zip_public_dir(repo_name, kickboard_public_path)
      hash = SecureRandom.hex(10)
      command = "cd #{build_repo_path(repo_name)} && zip #{kickboard_public_path}/#{hash}.zip -r public/"
      exec(command)
      hash
    end

    def exec(command, opts = {})
      info, error, pid_and_exit_code = Open3.capture3(command)
      if !pid_and_exit_code.success? && !info.include?('nothing to commit')
        raise ShellScriptError, error
      end
      # exec(command, stdout: true)にしたら結果の出力が得られる
      # 現状logsで使われている
      if opts[:stdout]
        info
      end
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
