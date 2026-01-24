#!/usr/bin/env ruby
# bundler gem
require 'bundler/setup'
require 'listen'
require 'set'
require 'optparse'

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
listener = Listen.to('./') do |modified, added, removed|
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

# debounce worker
worker = Thread.new do
  while running
    sleep 3   # Samba対策の要
    files = nil

    mutex.synchronize do
      files = pending.to_a
      pending.clear
    end

    next if files.empty?

    puts "まとめて処理: #{files}"

    case params['m']
    when 'build'
      # system("makeobj ...")
    when 'watch'
    # watch 専用処理
      puts #{files}
    else
      # default
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
