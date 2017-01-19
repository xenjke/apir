[![Travis](https://travis-ci.org/xenjke/apir.svg?branch=master)](https://travis-ci.org/xenjke/apir)
[![Coverage](https://coveralls.io/repos/github/xenjke/apir/badge.svg?branch=master)](https://coveralls.io/github/xenjke/apir?branch=master)
[![Code Climate](https://codeclimate.com/github/xenjke/apir/badges/gpa.svg)](https://codeclimate.com/github/xenjke/apir)

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

```ruby
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
```

[More examples.](https://github.com/xenjke/apir/tree/master/spec/apir/examples)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xenjke/apir. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

After checking out the repo, run `rake spec` or `rake` to run the tests.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

