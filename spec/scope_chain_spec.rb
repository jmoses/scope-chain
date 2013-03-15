lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'mocha/api'
require 'scope_chain'

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
      subject.expects(:add_link).with(link, :arguments, klass)

      subject.send(link, :arguments)
    end
  end

  it "has an all link" do
    subject.should respond_to(:all)
  end

  it "adds a link for all" do
    subject.expects(:add_link).with(:all, nil, :boom)

    subject.all(:boom)
  end

  describe "#add_link" do
    it "adds a basic expectation" do
      expectation = mock
      expectation.expects(:returns).with(:returned)

      klass.expects(:expects).with(:name).returns(expectation)

      subject.send :add_link, :name, nil, :returned
    end

    it "adds an expectation with arguments" do
      expectation = mock
      expectation.expects(:with).with(:arguments)
      expectation.expects(:returns).with(:returned)

      klass.expects(:expects).with(:name).returns(expectation)

      subject.send :add_link, :name, :arguments, :returned
    end
  end

end
