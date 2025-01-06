# Washcloth

Clean your Ruby strings.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'washcloth'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install washcloth
```

## Usage

First, register values to filter:

```ruby
Washcloth.filter(:encrypted_password)
```

Next, call `Washcloth.clean`:

```ruby
Washcloth.clean(%(<User encrypted_password: "THIS IS MY PASSWORD">)) # => "<User encrypted_password: \"*******************\">"
```

You can override how replacement values are generated:

```ruby
Washcloth.filter(:encrypted_password, filter: Washcloth.filters.static("[FILTERED]"))
Washcloth.filter(:encrypted_password, filter: Washcloth.filters.block(->(value) { value.reverse }))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/joshuaclayton/washcloth>. Please don't make adjustments to the version number in any submitted PRs, as this will be managed by project maintainers.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joshuaclayton/washcloth/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Washcloth project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joshuaclayton/washcloth/blob/main/CODE_OF_CONDUCT.md).
