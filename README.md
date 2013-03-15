# ScopeChain

ScopeChain is a tiny help class useful for testing ActiveRecord model scope usage
and scope chaining

# Usage

For example, say you have:

    class User < ActiveRecord::Base
    end

And you use that model:

    def some_method
      User.where(active: 1).order("created_at desc")
    end

And you want to test that method, but without setting creating data in your database,
or actually using the data base.

Using ScopeChain, you do:

    context "my method" do
      it "gets the right users" do
        ScopeChain.for(User).where(active: 1).order("created_at desc")

        some_method
      end
    end

What this will do is setup some expectations that make sure those scope methods are called.

Not in order, but called, which is something, right?

## Installation

Add this line to your application's Gemfile:

    gem 'scope-chain'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scope-chain

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
