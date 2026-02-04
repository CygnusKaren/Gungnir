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
opts.on('-d MODE') { |v|
  params['d'] = v
}
opts.parse!(ARGV)

# listen
listener = Listen.to('./',only: /\.dat$|\.png|\.rb$/) do |modified, added, removed|
  # デバッグ出力（そのまま残す）
  puts "変更: #{modified}" unless modified.empty?
  puts "追加: #{added}"    unless added.empty?
  puts "削除: #{removed}"  unless removed.empty?
  
  # デバウンス用キューに積む
  mutex.synchronize do
    (modified + added + removed).each do |path| # イベントを一括で配列化
      next if File.directory?(path) # ディレクトリは飛ばす
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

    # DSLファイルの更新チェック 


    # メイン処理
    @cmd = []
    files.each do | file |
      # ファイル名を取得
      b_file = File.basename(file)
      if File.extname(file) == ".rb"
        puts "DSLファイルが更新されました"
        loadDSL
        index = fileIndex()
        export = exportPath()
      end
      # インデックスファイルを走査
      if index[b_file] 
        # 該当あり
        pp index[b_file] # 該当プロジェクトデータを出力
        index[b_file].each do  |pak| # プロジェクトデータの切り出し
          exportPath = "#{export}#{pak.pak_file}"
          puts "Target:#{b_file} -> Project:#{pak.name}" # 更新ファイルとプロジェクトの紐付け
          puts "ExportPath: #{exportPath}" # 出力ファイル名の出力
          # コマンドを生成する
          @cmd = [
            "makeobj_60-5",
            "pak",
            exportPath,
            "#{pak.file_dirs}#{pak.dat_files.join(',')}"
          ]

          # Command execution
          case params['m'] # 引数"m"とオプション
          when 'build'
            stdout, stderr, status = Open3.capture3(*@cmd)
            # 標準出力
            puts stdout
            # エラー
            puts stderr
            # status
            puts status
          when 'debug' # デバッグモード
            puts @cmd
          else
            # default
          end
          puts "========================"
        end
      else
        # 該当無し
        puts "Target:#{file} -> Project not found."
      end
    end

    
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
