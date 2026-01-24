#!/usr/bin/env ruby
# bundler gem
require 'bundler/setup'
require 'listen'
require 'set'
require 'optparse'
require 'open3'
require_relative 'gungnir_dsl'

# mutexed
pending = Set.new
mutex = Mutex.new
running = true

# params
params = {}

# options
opts = OptionParser.new
opts.on('-m MODE') { |v|
  params['m'] = v
}
opts.parse!(ARGV)

p ARGV
puts params

# listen
listener = Listen.to('./',only: /\.dat$|\.png$/) do |modified, added, removed|
  # デバッグ出力（そのまま残す）
  puts "変更: #{modified}" unless modified.empty?
  puts "追加: #{added}"    unless added.empty?
  puts "削除: #{removed}"  unless removed.empty?

  # デバウンス用キューに積む
  mutex.synchronize do
    (modified + added + removed).each do |path|
      next if File.directory?(path)
      pending << path
    end
  end
end

listener.start
puts "Monitor Start..."
index = fileIndex()
export = exportPath()
# pp index
# debounce worker
worker = Thread.new do
  while running
    sleep 5   # Samba対策の要
    files = nil

    mutex.synchronize do
      files = pending.to_a
      pending.clear
    end

    next if files.empty?
    puts "処理開始"
    puts "まとめて処理: #{files}"
    
    case params['m'] # 引数"m"とオプション
    when 'build'
      #puts "ターゲット: #{files}"
      # インデックスを走査する
      files.each do | file |
        file = File.basename(file)
        if index[file] # インデックスへの確認
          # 該当あり
          pp index[file] # 該当プロジェクトデータを出力
          index[file].each do  |pak| # プロジェクトデータの切り出し
            exportPath = "#{export}#{pak.pak_file}"
            puts "Target:#{file} -> Project:#{pak.name}" # 更新ファイルとプロジェクトの紐付け
            puts "ExportPath: #{exportPath}" # 出力ファイル名の出力
            cmd = [
              "makeobj_60-5",
              "pak",
              exportPath,
              *pak.dat_files
            ]
            stdout , stderr, status = Open3.capture3(*cmd)
          end

          # 
          
        else
          # 該当無し
            puts "Target:#{file} -> Project not found."
        end
      end
      # system("makeobj ...")
    when 'watch'
    # watch 専用処理
      puts #{files}
    else
      # default
    end
    puts "========================"
  end
end

# graceful shutdown
trap('INT') do
  puts "\nStopping..."
  running = false
  listener.stop
  worker.join
  exit
end

sleep
