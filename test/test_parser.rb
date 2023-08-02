require 'test/unit'
require 'rolan/parser'
require 'rolan/lexer'
require 'rolan/engine'

class TestParser < Test::Unit::TestCase
  def test_parse
    src = '1.0 + 2'
    l = Rolan::Lexer.new(src)
    ps = Rolan::Parser.new(l)
    e = Rolan::Engine.new
    pp ast = ps.parse
    pp e.eval(nil, ast)
  end
end

