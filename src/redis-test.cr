require "redis"

r = Random.new

filepath = "rand-#{r.hex(4).to_s}"

def cleanup(filepath)
  File.delete(filepath) if File.exists?(filepath)
end

Signal::INT.trap do
  puts "shutting down"
  cleanup(filepath)
end

Signal::STOP.trap do
  cleanup(filepath)
end

puts "Preparing KV data file: " + filepath
file = File.open(filepath, "w") do |io|
  200000.times do
    data = r.hex(8).to_s + "," + r.base64(512).to_s
    io.puts(data)
  end
  io.flush
end
filesize = (File.size(filepath)/1024/1024).round(2)
puts "File created, and is #{filesize} MB"

redis = Redis::PooledClient.new

puts "Writing to Redis"
begin
  200000.times do |i|
    puts "iteration #{i}"
    File.each_line filepath do |line|
      key, value = line.split(",")
      redis.set(key, value)
    end
  end
rescue ex
  STDERR.puts ex
  cleanup(filepath)
  exit 1
end
