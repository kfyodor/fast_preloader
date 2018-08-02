# Graph-based Associations Preloader for Rails' ActiveRecord

A faster way to preload complex ActiveRecord associations graphs that uses way less queries.

Why?
Just check the logs. (TODO: Pics later)

How it works?
- Associations are added to the DAG (direct acyclic graph) where vetrices are "models" and edges are relationships between them.
- `tsort` the DAG in order to determine proper associations load order
- Load assocs using as few queries as possible. Best case scenario: one query per table (not per association as Rails does), though in presence of scopes there can be more queries per table.

TODO: proper description later

Supported Rails versions: 5.0 (later), 5.1 (only this one for now), 5.2 (later)

## Installation

Add this line to your application's Gemfile:

```ruby
# it's still alpha, I'll push it to Rubygems as soon as specs and perftests are done
gem 'fast_preloader', git: 'https://github.com/konukhov/fast_preloader'
```

And then execute:

    $ bundle

	
## Caveats

This gem is in early development so:
- Doest't support polymorphic records yet
- It cannot load circular references (User->Comment, Comment->User) yet. Rails can because it loads each association independently.
- I'm sure it has a lot of bugs

TODO: perf, specs etc.

## Usage

Enable/disable globally:

```ruby
# put it in config/initializers/fast_preloader.rb
FastPreloader.enable!
```

... for a particular model

```ruby
class SomeModel < ApplicationRecord
  # enabled
  fast_preloader
  
  # same
  fast_preloader true 
  
  # disabled for this model if enabled globally
  fast_preloader false 
end
```

... or for a particuar query or scope

```ruby
# enable for query
SomeModel.use_fast_preloader.includes(:some, associations: [:custom, :preloading])

# disable for query if enabled globally or for this model
SomeModel.use_fast_preloader(false).includes(:some, associations: [:rails, :preloading]) 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/konukhov/fast_preloader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fast Preloader project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/activerecord_preloader/blob/master/CODE_OF_CONDUCT.md).
