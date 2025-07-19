@c_scanned = {}
@m_scanned = {}
@v_scanned = {}

module Kernel
  def autoload sym, path
    warn sym
    warn path
    require path
  end
end

def gen(klass)
  @c_scanned[klass.to_s] = 1

  klass.public_instance_methods(false).each do |m|
    next if m.length < 3
    @m_scanned[m] = 1
    # klass.to_s + "." + 
  end
  klass.protected_instance_methods(false).each do |m|
    next if m.length < 3
    @m_scanned[m] = 1
  end

  klass.public_methods(false).each do |m|
    next if m.length < 3
    @m_scanned[m] = 1
  end

  klass.protected_methods(false).each do |m|
    next if m.length < 3
    @m_scanned[m] = 1
  end

  klass.included_modules.each do |m|
    gen(m)
  end   

  #klass.public_methods.each do |m|
  #  @m_scanned[m] = 1
  #end

end

ObjectSpace.each_object(Class) do |klass|
  gen klass
end

ObjectSpace.each_object(Module) do |klass|
  gen klass
end


@c_scanned.each_key do |c|
  puts "        <word name='#{c}'/>"
end

2.times { puts }

@m_scanned.each_key do |m|
  puts "        <word name='#{m}'/>"
end

2.times { puts }

@v_scanned.each_key do |v|
  puts "    <word name='%{v}'/>"
end
