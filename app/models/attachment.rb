require Rails.root.join('script/shell_script_runner')

class Attachment < ApplicationRecord
  # TODO: ImageをFileにリネーム
  include ImageUploader[:file]

  after_commit :unzip

  def unzip
    ShellScriptRunner.unzip_to_public(self.file.url, self.repo_name)
  end

  def commit
    ShellScriptRunner.commit_and_push
  end
end
