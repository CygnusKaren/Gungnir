require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['*.rb']   # 修正: .yardopts がある場合はそちらが優先されますが、一応指定
  t.options = []          # .yardopts から読み込まれます
end

task default: :yard
