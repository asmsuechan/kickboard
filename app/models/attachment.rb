require Rails.root.join('script/shell_script_runner')

class Attachment < ApplicationRecord
  DEFAULT_COMMIT_MESSAGE = '[auto commit from kickboard]'.freeze
  REPOSITORIES = YAML.load_file(SETTING_PATH)['names'].freeze

  # TODO: アップロードするzipの制約等コメントに残す
  # アプロードするzipファイルはフォルダ丸ごとzipで圧縮してください。
  include FileUploader[:file]
  include ShellScriptRunner

  # 存在しないディレクトリを弾く
  validates :repo_name, inclusion: { in: REPOSITORIES }

  before_save :set_commit_message
  after_commit :unzip
  after_commit :commit

  def unzip
    ShellScriptRunner.unzip_to_public(self.file.url, self.repo_name)
  end

  def commit
    ShellScriptRunner.commit_and_push(self.repo_name, self.message)
  end

  def set_commit_message
    self.message ||= DEFAULT_COMMIT_MESSAGE unless self.message
  end
end
