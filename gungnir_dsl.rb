#!/usr/bin/env ruby

# DSL定義部分
class Project
  attr_reader :name, :paks, :common_files

  def initialize(name, &block) # 初期化 プロジェクト名を受け入れる
    @name = name # プロジェクト名
    @paks = [] # 生成pak名
    @common_files = [] # 共通ファイル(アイコン等)
    instance_eval(&block) if block_given?
  end

  def commonFiles(*files) # 共通ファイル取り込み
    @common_files.concat(files)
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
    @dat_files = []
    @png_files = []
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

require_relative 'project_dsl.rb' # プロジェクトのプロパティファイルは共通名とする

# 出力確認
proj = build_project()
puts "Common: #{proj.common_files.join(',')}"
proj.paks.each do |pak|
   puts "Pak: #{pak.name}"
  puts "  pak: #{pak.pak_file}"
  puts "  dat: #{pak.dat_files.join(', ')}"
  puts "  png: #{pak.png_files.join(', ')}"
end
