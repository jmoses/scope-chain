require "scope_chain/version"

module ScopeChain
  def self.for(klass, &block)
    Chain.new klass, &block
  end

  class Chain
    LINKS = [:select, :where, :includes, :order]

    attr_accessor :klass, :expectations
    def initialize(klass, &block)
      self.klass = klass
      self.expectations = []
      self.klass.stubs(scoped: klass) # Handle manual scope building

      yield self if block_given?
    end

    LINKS.each do |link|
      define_method(link) do |*arguments|
        add_link link, *arguments
      end
    end

    def all(returned)
      add_link :all
      returns returned
    end

    def returns(object)
      # DON'T LOOK
      expectations.last.instance_variable_set(:@return_values, Mocha::ReturnValues.build(object))
      
      self
    end

    private
    def add_link(name, *arguments)
      expectation = klass.expects(name)
      expectation.with(*arguments) if arguments.size > 0
      expectation.returns(klass)

      expectations << expectation

      self
    end
  end
end
