# PandocObjectFilters

This is a simple gem that is a fork of
https://github.com/karaken12/pandoc-filters-ruby but providing Pandoc filters
via objects. It's possible this gem may get deprecated if the functionality is
merged into the `pandoc-filter` gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "pandoc_object_filters"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pandoc_object_filters

## Usage

For now, see the [examples](examples).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pandoc_object_filters. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
