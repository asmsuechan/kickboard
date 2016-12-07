require Rails.root.join('script/shell_script_runner')

class Attachment < ApplicationRecord
  # TODO: ImageをFileにリネーム
  include ImageUploader[:file]
  # a

  after_commit :commit

  def commit
    ShellScriptRunner.commit_and_push
  end
end
