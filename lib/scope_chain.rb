require "scope_chain/version"

module ScopeChain
  def self.for(klass, &block)
    Chain.new klass, &block
  end

  class Chain
    LINKS = [:select, :where, :includes, :order]

    attr_accessor :klass
    def initialize(klass, &block)
      self.klass = klass
      self.klass.stubs(scoped: klass) # Handle manual scope building

      yield self if block_given?
    end

    LINKS.each do |link|
      define_method(link) do |arguments = nil, returned = nil|
        add_link link, arguments, returned || klass
      end
    end

    def all(returned)
      add_link :all, nil, returned
    end

    private
    def add_link(name, arguments = nil, returned = klass)
      expectation = klass.expects(name)
      expectation.with(arguments) if arguments
      expectation.returns(returned)

      self
    end
  end
end
