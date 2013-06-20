# TreeWalker

Creates a graph of model dependencies for your rails app.
Once it's created, it walks that graph to create a tree of associations starting at one node; that tree can be used in an ActiveRecord include method to load all associated dependencies

The graph dependencies code was scavenged from railroady 

## Installation

Add this line to your application's Gemfile:

    gem 'tree_walker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tree_walker

## Usage

```
tree = ModelAssociationTreeGenerator.new.run("MyModel")
MyModel.include(tree).where(id=1)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
