#!/usr/bin/env ruby

# DSL定義部分
class Project
  attr_reader :name, :paks, :common_files, :export_path

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
  
  def pakName(name, &block) # pak1個のプロパティを入力
    pak = Pak.new(name)
    pak.instance_eval(&block) if block_given?
    @paks << pak
  end
end

class Pak # pak単独クラス
  attr_accessor :name, :pak_file, :dat_files, :png_files 

  def initialize(name) # 初期化 pak関連のデータを受け入れる
    @name = name
    @type_status = nil
    @dat_files = []
    @png_files = []
  end

  def type(type)
    @type_status = type
  end
  
  def pak(file) 
    @pak_file = file
  end

  def dat(*files)
    @dat_files.concat(files)
  end

  def png(*files)
    @png_files.concat(files)
  end
end

# DSLファイルを読み込む
# 作業ディレクトリ側の DSL を読む
dsl_file = File.join(Dir.pwd, 'project_dsl.rb')

unless File.exist?(dsl_file)
  abort "project_dsl.rb が見つかりません: #{dsl_file}"
end
require dsl_file

# 逆引き用のインデックスを作る
@file_to_paks = {}

# 出力確認
@proj = build_project()

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
  # puts "Pak: #{pak.name}"
  # puts "  pak: #{pak.pak_file}"
  # puts "  dat: #{pak.dat_files.join(', ')}"
  # puts "  png: #{pak.png_files.join(', ')}"
  # puts "=========================="
end

def fileIndex
  return @file_to_paks
end

def exportPath
  return @proj.export_path
end
# pp @file_to_paks
