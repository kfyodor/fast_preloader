# Rails Altenative Association Preloader (RAAP)

A faster way to preload ActiveRecord associations in Rails that uses way less queries in complex `includes` graphs.

How it works?
- Associations are added to the DAG (direct acyclic graph) where vetrices are "models" and edges are relationships between them.
- `tsort` the DAG in order to determine proper associations load order
- Load assocs using as few queries as possible. Best case scenario: one query per table (not per association as Rails does), though in presence of scopes there can be more queries per table.

TODO: proper description later

Supported Rails versions: 5.0 (later), 5.1 (only this one for now), 5.2 (later)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'raap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raap
	
## Caveats

This gem is in early development so:
- It doesn't have `through` assocs support yet (soon)
- Doest't support polymorphic records yet
- It cannot properly load self references (e.g. `User.has_one :inviter, class_name: 'User'`)
- It cannot load circular references (User->Comment, Comment->User) yet. Rails can because each association it loads each assoc independently.

## Usage

To use globally:

```ruby
# put it in config/initializers/raap.rb
Raap.enable!
```

To use in a model

```ruby
class SomeModel < ApplicationRecord
  raap # enabled
  raap true # same
  raap false # disabled for this particular model
end
```

To use in a scope

```ruby
SomeModel.includes(:some, associations: [:custom, :preloading]).with_raap # enable for query
SomeModel.includes(:some, associations: [:rails, :preloading]).with_raap(false) # disable for query
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/konukhov/raap. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RAAP project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/activerecord_preloader/blob/master/CODE_OF_CONDUCT.md).
