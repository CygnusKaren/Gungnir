#!/usr/bin/env ruby
# bundler gem
require 'bundler/setup'

# デバッグ用オプション
params = {}
unless defined?(OptionParser)
  require 'optparse'
  opts = OptionParser.new
  opts.on('-d MODE') { |v|
    params['d'] = v
  }
  opts.parse!(ARGV)
  
  # p ARGV
  # puts params  
end
require 'optparse'
require 'open3'

# DSL定義部分
class Project
  attr_reader :name, :paks, :common_files, :export_path, :file_dirs

  def initialize(name, &block) # 初期化 プロジェクト名を受け入れる
    @name = name # プロジェクト名
    @paks = [] # 生成pak名
    @common_files = [] # 共通ファイル(アイコン等)
    @export_path = nil
    instance_eval(&block) if block_given?
  end

  def commonFiles(*files) # 共通ファイル取り込み
    @common_files.concat(files)
  end

  def exportPath(path) # 共通ファイル取り込み
    @export_path = path
  end
  
  def workingDir(dir) # 共通ファイル取り込み
    @working_dir = dir
  end

  def pakName(name, dir: "./", &block) # pak1個のプロパティを入力
    pak = Pak.new(name)
    pak.instance_eval(&block) if block_given?
    @paks << pak
  end

  def pakEach(list,prefix:, dir: "./", &block) # 複数のpakを一括定義する
    # listで変化部
    # prefix: 変数の接頭辞(必須)
    list.each do |v|
      pakName "#{prefix}-#{v}" do # paknameは内部参照用として割り切る、prefix + 方向で定義
        instance_exec(v, &block)  # ブロックに v を渡す
      end
    end
  end
  
end

class Pak # pak単独クラス
  attr_accessor :name, :pak_file, :dat_files, :png_files, :file_dirs

  def initialize(name) # 初期化 pak関連のデータを受け入れる
    @name = name
    @type_status = nil
    @dat_files = []
    @png_files = []
    @file_dirs = "./"
  end

  def type(type) # addon type
    @type_status = type
  end
  
  def pak(file) # pakname
    @pak_file = file
  end

  def dat(*files) # using dat file
    @dat_files.concat(files)
  end

  def png(*files) # using png image
    @png_files.concat(files)
  end

  def dir(dir)
    @file_dirs = dir
  end
end

def loadDSL
  # DSLファイルを読み込む
  # 作業ディレクトリ側の DSL を読む
  dsl_file = File.join(Dir.pwd, 'project_dsl.rb')
    unless File.exist?(dsl_file)
    abort "project_dsl.rb が見つかりません: #{dsl_file}"
  end
  Object.send(:remove_const, :Gungnir_DSL) if defined?(Gungnir_DSL)
  load dsl_file  
  @file_to_paks = {} 

end

# dslファイルをロードする
loadDSL
# 逆引き用のインデックスを作る

# 出力確認
@proj = Gungnir_DSL.build_project()

# 共通・基本項目
puts "Common: #{@proj.common_files.join(',')}"
puts "ExportPath: #{@proj.export_path}"

# 各pak毎の出力
puts "=========================="
@proj.paks.each do |pak|
  (pak.dat_files + pak.png_files).each do |f|
    @file_to_paks[f] ||= []
    @file_to_paks[f] << pak
  end
  case params['d']
  when 'debug'
  puts "Pak: #{pak.name}"
  puts "  pak: #{pak.pak_file}"
  puts "  dat: #{pak.dat_files.join(', ')}"
  puts "  png: #{pak.png_files.join(', ')}"
  puts "  dir: #{pak.file_dirs}"
  puts "=========================="
  end
end

def fileIndex
  return @file_to_paks
end

def exportPath
  return @proj.export_path
end
# pp @file_to_paks
