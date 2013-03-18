lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'active_record'
require 'mocha/api'
require 'scope_chain'

ActiveRecord::Base.establish_connection({
  adapter: 'sqlite3',
  database: ":memory:",
  verbosity: 'quiet'
})

ActiveRecord::Base.connection.create_table :models do |table|
  table.belongs_to :owners
  table.integer :column
end

ActiveRecord::Base.connection.create_table :owners

class Model < ActiveRecord::Base
  scope :active, where("column = value")
end

class Owner < ActiveRecord::Base
  has_many :models
end

describe ScopeChain do
  let(:klass) { Class.new }

  it "yields" do
    expect {|b| ScopeChain.for(klass, &b) }.to yield_control
  end

  it "uses the right klass" do
    ScopeChain.for(klass).klass.should eq(klass)
  end
end

describe ScopeChain::Chain do
  let(:klass) { Class.new }
  subject { described_class.new(klass) }

  ScopeChain::Chain::LINKS.each do |link|
    it "has a #{link} link" do
      subject.should respond_to(link)
    end
    
    it "adds a link for #{link}" do
      subject.expects(:add_link).with(link, :arguments)

      subject.send(link, :arguments)
    end
  end

  it "has an all link" do
    subject.should respond_to(:all)
  end

  it "adds a link for all" do
    subject.expects(:add_link).with(:all)
    subject.expects(:returns).with(:boom)

    subject.all(:boom)
  end

  it "supports manual scopes" do
    subject.select("id")

    klass.scoped.select("id")
  end

  it "works with the alias scopes" do
    subject.new(5)

    klass.new(5)
  end

  describe "#returns" do
    it "modifies the last expectation" do
      subject.select("id").where("5").returns("9")

      klass.select("id").where("5").should eq("9")
    end
  end

  describe "#add_link" do
    it "adds a basic expectation" do
      expectation = mock
      expectation.expects(:returns).with(klass)

      klass.expects(:expects).with(:name).returns(expectation)

      subject.send :add_link, :name
    end

    it "adds an expectation with arguments" do
      expectation = mock
      expectation.expects(:with).with(:arguments)
      expectation.expects(:returns).with(klass)

      klass.expects(:expects).with(:name).returns(expectation)

      subject.send :add_link, :name, :arguments
    end
  end

  describe "#exists!" do
    it "exists" do
      subject.exists!

      klass.should be_exists
    end
  end

  describe "#missing!" do
    it "does not exist" do
      subject.missing!

      klass.should_not be_exists
    end
  end

  describe "with a custom scopes" do
    it "fails properly" do
      pending

      ScopeChain.for(Model).where("column != value")

      expect { Model.active.to_a }.to raise_error(Mocha::StubbingError)
    end

    it "passes properly" do
      pending

      ScopeChain.for(Model).where("column = value")

      Model.active.to_a
    end
  end

  context "with associations" do
    describe "has_many" do
      it "properly sets stuff up" do
        source = Owner.new
        ScopeChain.on(source).as(:models).new(column: 5).returns(:abc)

        source.models.new(column: 5).should eq(:abc)
      end
    end
  end

end
