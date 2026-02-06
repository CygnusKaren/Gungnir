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
# Simutransのプロジェクトを定義するクラス
class Project
  # @return [String] プロジェクト名
  attr_reader :name
  # @return [Array<Pak>] 定義されたpakのリスト
  attr_reader :paks
  # @return [Array<String>] 共通ファイルのリスト
  attr_reader :common_files
  # @return [String, nil] 出力先パス
  attr_reader :export_path
  # @return [String, nil] 作業ディレクトリ
  attr_reader :file_dirs

  # プロジェクトを初期化する
  # @param name [String] プロジェクト名
  # @yield プロジェクトの構成を定義するブロック
  def initialize(name, &block)
    @name = name
    @paks = []
    @common_files = []
    @export_path = nil
    instance_eval(&block) if block_given?
  end

  # 共通ファイル（アイコンなど）を追加する
  # @param files [Array<String>] 追加するファイル名
  def commonFiles(*files)
    @common_files.concat(files)
  end

  # pakの出力先パスを設定する
  # @param path [String] 出力先パス
  def exportPath(path)
    @export_path = path
  end
  
  # 作業ディレクトリを設定する
  # @param dir [String] ディレクトリパス
  def workingDir(dir)
    @working_dir = dir
  end

  # 単一のpakを定義する
  # @param name [String] pak名（内部参照用）
  # @param dir [String] ファイルのディレクトリ
  # @yield pakの詳細を定義するブロック
  def pakName(name, dir: "./", &block)
    pak = Pak.new(name)
    pak.instance_eval(&block) if block_given?
    @paks << pak
  end

  # 複数のpakを一括定義する
  # @param list [Array] 変化する値のリスト
  # @param prefix [String] pak名の接頭辞
  # @param dir [String] ファイルのディレクトリ
  # @yield [v] 各要素に対して実行されるブロック
  # @yieldparam v [Object] リストの要素
  def pakEach(list, prefix:, dir: "./", &block)
    list.each do |v|
      pakName "#{prefix}-#{v}" do
        instance_exec(v, &block)
      end
    end
  end
end

# 単一のpakファイルを定義するクラス
class Pak
  # @return [String] pak名
  attr_accessor :name
  # @return [String] pakファイル名
  attr_accessor :pak_file
  # @return [Array<String>] 使用するdatファイル
  attr_accessor :dat_files
  # @return [Array<String>] 使用するpngファイル
  attr_accessor :png_files
  # @return [String] ファイルのディレクトリ
  attr_accessor :file_dirs

  # Pakを初期化する
  # @param name [String] pak名
  def initialize(name)
    @name = name
    @type_status = nil
    @dat_files = []
    @png_files = []
    @file_dirs = "./"
  end

  # アドオンの種類を設定する
  # @param type [String] 種類
  def type(type)
    @type_status = type
  end
  
  # pakファイル名を設定する
  # @param file [String] ファイル名
  def pak(file)
    @pak_file = file
  end

  # 使用するdatファイルを追加する
  # @param files [Array<String>] datファイル名
  def dat(*files)
    @dat_files.concat(files)
  end

  # 使用するpngファイルを追加する
  # @param files [Array<String>] pngファイル名
  def png(*files)
    @png_files.concat(files)
  end

  # ファイルのディレクトリを設定する
  # @param dir [String] ディレクトリパス
  def dir(dir)
    @file_dirs = dir
  end
end

# DSLファイルを読み込む
# @return [void]
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

# ファイル名からPakオブジェクトへの逆引きインデックスを取得する
# @return [Hash{String => Array<Pak>}]
def fileIndex
  return @file_to_paks
end

# プロジェクトの出力先パスを取得する
# @return [String, nil]
def exportPath
  return @proj.export_path
end
# pp @file_to_paks
