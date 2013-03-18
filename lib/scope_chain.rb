require "scope_chain/version"

module ScopeChain
  module RspecHelpers
    def scope_chain(&block)
      ScopeChain.for(described_class, &block)
    end
  end

  def self.for(klass, &block)
    Chain.new klass, &block
  end

  def self.on(instance)
    AssociationChain.new instance
  end

  class AssociationChain
    attr_accessor :instance, :association

    def initialize(instance)
      self.instance = instance
    end

    def as(association_name)
      self.association = instance.class.reflect_on_association(association_name)

      chain
    end

    private
    def association_name(klass)
      klass.name.underscore.pluralize
    end

    def chain
      ScopeChain::Chain.new(association.klass).tap do |chain|
        instance.stubs(association.name => association.klass)
      end
    end
  end

  class Chain
    LINKS = [:select, :where, :includes, :order, :find, :sum, :new, :create, :create!]
    ALIASES = {} 

    class ConflictedExistenceError < StandardError
    end

    attr_accessor :klass
    def initialize(klass, &block)
      self.klass = klass
      @expectations = []
      @exists_condition = false

      link_manual_scopes
      link_named_scopes

      yield self if block_given?
    end

    LINKS.each do |link|
      define_method(link) do |*arguments|
        add_link link, *arguments
      end
    end

    ALIASES.each do |source, dest|
      define_method(source) do |*arguments|
        add_link dest, *arguments
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

    def link_manual_scopes
      klass.stubs(scoped: klass) # Handle manual scope building
    end

    def link_named_scopes
      return unless klass.respond_to?(:scopes) && klass.scopes.present?

      klass.scopes[klass.name].each do |named|
        self.define_singleton_method(named) do |*arguments|
          add_link named, *arguments
        end
      end
    end

  end
end

# Hooks so named scopes are sane
class ActiveRecord::Base
  cattr_reader :scopes
  def self.scope_with_tracking(*args, &block)
    (@@scopes ||= Hash.new {|hash, key| hash[key] = [] })[self.name].push args.first
    scope_without_tracking *args, &block
  end

  class << self
    alias_method_chain :scope, :tracking
  end
end
