require 'rolan/value'

module Rolan
  class Context
    def initialize(parent)
      @parent = parent
      @env = {}
    end

    attr_reader :env
    protected :env

    def define(ident, val)
      @env[ident] = val
    end

    def [](ident)
      lookup(ident).env[ident]
    end

    def []=(ident, val)
      lookup(ident).env[ident] = val
    end

    protected def lookup(ident)
      case
      when @env[ident]
        self
      when @parent
        @parent.lookup(ident)
      else
        self
      end
    end
  end

  class Engine
    def initialize
      @global = prelude(Context.new(nil))
    end

    private def prelude(cxt)
      cxt.define(:println, Value::NativeFunction.new(:println){|args| puts args.map(&:to_string) })
      cxt
    end

    def run(ast)
      eval @global, ast
    end

    private

    def eval(cxt, ast)
      case ast
      in AST::Stmts
        ast.children.each do |st|
          eval(cxt, st)
        end
      in AST::Call
        fn = cxt[ast.name]
        args = ast.args.map{|x| eval cxt, x }
        case fn
        in Value::NativeFunction
          fn.call(args)
        end
      in AST::Binary
        l = eval(cxt, ast.left)
        r = eval(cxt, ast.right)
        l.send(ast.op, r)
      in AST::Int
        Value.int_value ast.value
      in AST::Float
        Value.float_value ast.value
      in AST::String
        Value.string_value ast.value
      end
    end
  end
end

