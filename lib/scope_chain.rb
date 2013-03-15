require "scope_chain/version"

module ScopeChain
  def self.for(klass, &block)
    Chain.new klass, &block
  end

  class Chain
    LINKS = [:select, :where, :includes, :order]

    class ConflictedExistenceError < StandardError
    end

    attr_accessor :klass
    def initialize(klass, &block)
      self.klass = klass
      @expectations = []
      @exists_condition = false
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
      @expectations.last.instance_variable_set(:@return_values, Mocha::ReturnValues.build(object))
      
      self
    end

    def exists!
      set_exists true
    end

    def missing!
      set_exists false
    end

    private
    def add_link(name, *arguments)
      expectation = klass.expects(name)
      expectation.with(*arguments) if arguments.size > 0
      expectation.returns(klass)

      @expectations << expectation

      self
    end

    def set_exists(value)
      if @exists_condition
        raise ConflictedExistenceError.new("Can only set one 'exists' conditions, #missing! or #exists!")
      end

      klass.expects(exists?: value)
      @exists_condition = true

      self
    end

  end
end
