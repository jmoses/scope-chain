# ScopeChain

ScopeChain is a tiny helper class useful for testing ActiveRecord model scope usage
and scope chaining

# Usage

For example, say you have:
```ruby
class User < ActiveRecord::Base
end
```

And you use that model:
```ruby
def some_method
  User.where(active: 1).order("created_at desc")
end
```

And you want to test that method, but without creating data in your database,
or actually using the data base.

Using ScopeChain, you do:
```ruby
context "my method" do
  it "gets the right users" do
    ScopeChain.for(User).where(active: 1).order("created_at desc")
    some_method
  end
end
```

What this will do is setup some expectations that make sure those scope methods are called.

You can do "manual" scopes:
```ruby
def manual_scopes
  User.scoped.where("something = else")
end

it "does the right thing" do
  ScopeChain.for(User).where("something = else")
  manual_scopes
end
```

You can test return values:
```ruby
def return_values
  User.where("thing = 1")
end

it "returns properly" do
  ScopeChain.for(User).where("thing = 1").returns(5)

  return_values.should eq(5)
end
```

You can test associations on individual model instances:

```ruby
class Model < ActiveRecord::Base
end

class Owner < ActiveRecord::Base
  has_many :models

  def my_method
    models.create(column: 5)
  end
end

def test_my_method
  owner = Owner.new
  ScopeChain.on(owner).as(:models).create(column: 5)

  owner.my_method
end

Not in order, but called, which is something, right?

## Known Issues

Uh, actual, user defined scopes don't work. Or if they do, I'd be surprised.  And I'm sure I'm
missing a bunch of the ActiveRecord methods that are used.

## Installation

Add this line to your application's Gemfile:

    gem 'scope_chain'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scope_chain

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
