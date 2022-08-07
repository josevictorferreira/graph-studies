require 'benchmark'
require 'async'

MEGABYTE = 2**20
FILENAME = './soc-LiveJournal1.txt'.freeze
FILE_SIZE = File.size(FILENAME).to_f / MEGABYTE
CHUNK_SIZE = (FILE_SIZE / 16).floor * MEGABYTE

def profile_memory
  memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i
  yield
  memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i

  used_memory = ((memory_usage_after - memory_usage_before) / 1024.0).round(2)
  puts "Memory usage: #{used_memory} MB"
end

def profile_time
  time_elapsed = Benchmark.realtime do
    yield
  end

  puts "Time: #{time_elapsed.round(2)} seconds"
end

def profile_gc
  GC.start
  before = GC.stat(:total_freed_objects)
  yield
  GC.start
  after = GC.stat(:total_freed_objects)

  puts "Objects Freed: #{after - before}"
end

def profile
  profile_memory do 
    profile_time do 
      profile_gc do
        yield
      end
    end 
  end 
end

profile do
  ractors = []
  File.open(FILENAME).each(nil, CHUNK_SIZE) do |chunk|
    require 'pry'; binding.pry
    ractors << Ractor.new(chunk) do |new_chunk|
      graph = {}
      new_chunk.split("\n").each do |line|
        next if line[0] == '#'

        from_node, to_node = line.split
        graph[from_node.to_i] = (graph[from_node.to_i] || []).append(to_node.to_i)
      end
      graph
    end
  end
  result = ractors.map(&:take)
  puts result[0]
end

