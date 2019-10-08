require "redis"

r = Random.new

filepath = "rand-" + r.hex(4).to_s

Signal::INT.trap do
  File.delete(filepath)
end

Signal::STOP.trap do
  File.delete(filepath)
end

puts "Generating file: " + filepath
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
10000.times do |i|
  puts "iteration #{i}"
  File.each_line filepath do |line|
    key, value = line.split(",")
    redis.set(key, value)
  end
end
