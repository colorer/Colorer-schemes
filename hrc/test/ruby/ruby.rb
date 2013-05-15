def foo(bar)
  bar.gsub(%r{^\.|[\s/\\\*\:\?'"<>\|]}, '_')
end