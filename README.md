[![Travis](https://travis-ci.org/xenjke/apir.svg?branch=master)](https://travis-ci.org/xenjke/apir)
[![Coverage](https://coveralls.io/repos/github/xenjke/apir/badge.svg?branch=master)](https://coveralls.io/github/xenjke/apir?branch=master)

# Apir

Module and Request class to help building RequestObject testing framework

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apir'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apir

Lock the gem version strictly to be safe from my destructive actions.

## Usage

    request = Apir::Request.new
    request.query = { param: 'value' }
    request.get!
    request.cookies = { basic: 'usage' }
    request.redo!
    request.cookie_jar # assert
    request.cookie_jar << HTTP::Cookie # modify

    class GetWeather
      include Apir::Request
      
      def initialize(**args)
        @url = 'https://weather.com'
        super(@url, args)
      end

      def post_initialize
        # hook to gain some control
        # after the request execution
        puts response # if JSON
        puts raw_response.code # RestClient response object
        @property = result
      end

      def result
        # bind desired response data
        response[:result] || {}
      end

      def sunny?(city)
        self.query.merge!(cityName: city)
        get!
        sun_factor > 3
      end

      def sun_factor
        result[:sunFactor]
      end
      
    end
    request = GetWeather.new
    request.sunny?('London')

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xenjke/apir. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

