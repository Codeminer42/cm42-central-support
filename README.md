# Central::Support

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/central/support`. To experiment with that code, run `bin/console` for an interactive prompt.

This is a library that moves away some of the logic from [Central](https://github.com/Codeminer42/cm42-central) so we can reuse in other projects. Particularly the Iteration calculation.

[![Code Climate](https://codeclimate.com/repos/57e072af8a0f4603260024d5/badges/3ed30d50ad1a44162204/gpa.svg)](https://codeclimate.com/repos/57e072af8a0f4603260024d5/feed)
[![Test Coverage](https://codeclimate.com/repos/57e072af8a0f4603260024d5/badges/3ed30d50ad1a44162204/coverage.svg)](https://codeclimate.com/repos/57e072af8a0f4603260024d5/coverage)
[![Build Status](https://travis-ci.org/Codeminer42/cm42-central-support.svg?branch=master)](https://travis-ci.org/Codeminer42/cm42-central-support)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'central-support'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install central-support

## Usage

This library expects a very specific set of pre-existing models (Team, Project, Story, User, Activity, Enrollment, Membership, and Ownership).

They are all models that exist in Central and they must also follow a specific database schema.

If you want to use this library in another application, refer to the `spec/support/rails_app/` so you know exactly how your new app should look like.

The application that links against this library must add the main models manually: Team, User, Project, Story, Note, Activity, and the many-to-many relationships, Membership, Enrollment, and Ownership. Again, refer to the spec dummy app example on how to do that.

This gem is not intended to have generators of any kind, just easily includable modules (Concerns), and helper libraries for the core of Central.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Codeminer-42/central-support.


## License

The gem is available as open source under the terms of the [LGPL License](https://www.gnu.org/licenses/lgpl-3.0.en.html).

