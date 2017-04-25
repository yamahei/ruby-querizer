
require "fileutils"

def assert(expect)
  result = nil
  begin
    result = yield
  rescue=>e
    result = e
  end
  puts "Assert: #{expect==result}"
  p result
  puts
end

def test(q, dir)
  if File.exists?(dir)
    Dir.chdir dir
    FileUtils.rm(Dir.glob('*.*'))
  end
  FileUtils.mkdir_p(dir)

  assert(true){
    q.parent.insert({:num=>1, :category=>"hoge"})
  }
  assert(1){
    q.parent.select.count
  }
  assert(1){
    q.parent.selectByNum({:num=>1}).count
  }
  assert(0){
    q.parent.selectByNum({:num=>2}).count
  }
  assert(1){
    q.parent.selectByCategory({:category=>"hoge"}).count
  }
  assert(0){
    q.parent.selectByCategory({:category=>"fuga"}).count
  }
end
