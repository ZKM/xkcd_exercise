file = File.open("menu.txt", 'r')
while !file.eof?
  line = file.readline
  puts line
end