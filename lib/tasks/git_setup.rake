require Rails.root.join('script/shell_script_runner')

# ObjectにShellScriptRunnerをincludeしたくないのでModuleで包んでいます
Module.new do
  extend Rake::DSL
  extend self
  include ShellScriptRunner

  namespace :git_setup do
    desc '最初のリポジトリclone用タスク'
    task clone: :environment do
      ShellScriptRunner.clone
    end
  end
end
