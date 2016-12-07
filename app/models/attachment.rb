require Rails.root.join('script/shell_script_runner')

class Attachment < ApplicationRecord
  include ShellScriptRunner
  # TODO: ImageをFileにリネーム
  include ImageUploader[:file]

  after_commit :unzip
  after_commit :commit

  def unzip
    ShellScriptRunner.unzip_to_public(self.file.url, self.repo_name)
  end

  def commit
    ShellScriptRunner.commit_and_push(self.repo_name)
  end
end
