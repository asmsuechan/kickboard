require "open3"
commit_info, error, pid_and_exit_code = Open3.capture3("git add . && git commit -m 'hoge' && git push origin HEAD")
puts commit_info
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
#
# クラス化してgit pushまでするメソッドとgitエラー時のメソッドとzipを展開するメソッドに分けたほうがいい
