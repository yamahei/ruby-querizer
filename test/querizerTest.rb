
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

  #insert + select
  assert(true){ q.parent.insert({:num=>1, :category=>"hoge"}) }
  assert(true){ q.parent.insert({:num=>2, :category=>"fuga"}) }
  assert(2){    q.parent.select.count }
  assert(1){    q.parent.selectByNum({:num=>1}).count  }
  assert(0){    q.parent.selectByNum({:num=>9}).count  }
  assert(1){    q.parent.selectByCategory({:category=>"hoge"}).count  }
  assert(0){    q.parent.selectByCategory({:category=>"HOGE"}).count  }
  #update + select
  assert(true){ q.parent.update({:category=>"HOGE"},{:num=>1, :category=>"hoge"})}
  assert(0){    q.parent.selectByCategory({:category=>"hoge"}).count  }
  assert(1){    q.parent.selectByCategory({:category=>"HOGE"}).count  }
  #delete + select
  assert(true){ q.parent.delete({:num=>2}) }
  assert(1){    q.parent.selectByCategory({:category=>"HOGE"}).count  }
  assert(0){    q.parent.selectByCategory({:category=>"fuga"}).count  }
  assert(1){    q.parent.selectByNum({:num=>1}).count  }
  assert(0){    q.parent.selectByNum({:num=>2}).count  }

end
