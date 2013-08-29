class Foo
  def self.bar
    @temp = 'x'
  end

  def self.baz
    @temp = 'y'
    return self
  end

  def self.qux
    @temp
  endrm foo
end
