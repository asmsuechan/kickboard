# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  file_data  :text
#  message    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  repo_name  :string           not null
#

require Rails.root.join('script/shell_script_runner')

class Attachment < ApplicationRecord
  DEFAULT_COMMIT_MESSAGE = '[auto commit from kickboard]'.freeze
  SETTING_PATH = "#{Rails.root}/config/repository.yml".freeze
  REPOSITORIES = YAML.load_file(SETTING_PATH)['names'].freeze

  # TODO: アップロードするzipの制約等コメントに残す
  # アプロードするzipファイルはフォルダ丸ごとzipで圧縮してください。
  include FileUploader[:file]
  include ShellScriptRunner

  # 存在しないディレクトリを弾く
  validates :repo_name, inclusion: { in: REPOSITORIES }

  # TODO: commit後なぜかUPDATEが走る
  before_save :set_commit_message
  before_create :pull
  after_create :unzip
  # TODO: commitのコード走らせてないような気がするけどcommitされる。調査。
  # after_save :commit

  def unzip
    ShellScriptRunner.unzip_to_public(self.file.url, self.repo_name)
  end

  def commit
    ShellScriptRunner.commit_and_push(self.repo_name, self.message)
  end

  def pull
    ShellScriptRunner.pull(self.repo_name)
  end

  def rollback(repo_name)
    ShellScriptRunner.rollback(repo_name)
  end

  def set_commit_message
    self.message ||= DEFAULT_COMMIT_MESSAGE unless self.message
  end
end
