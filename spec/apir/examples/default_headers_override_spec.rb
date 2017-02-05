require 'spec_helper'
require 'webmock/rspec'
WebMock.disable!

require 'apir'

describe 'Headers override' do
  let(:json_response) { JSON.unparse({ status: "AUTHORISED" }) }
  # mocking network
  before(:all) do
    WebMock.enable!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # unmocking network
  after(:all) do
    WebMock.allow_net_connect!
    WebMock.disable!
  end

  it 'before initialize' do
    url = "https://headers_override.com"
    stub_request(:any, url).to_return { |request| { body: json_response, headers: request.headers } }

    class RedifinedRequest < Apir::Request
      def default_headers
        { overriden_header: true }
      end
    end
    request = RedifinedRequest.new(url)

    expect(request.default_headers).to eq(overriden_header: true)
    expect(request.headers).to eq(request.default_headers)
    request.post!
    expect(request.raw_response.headers).to include(overriden_header: 'true')
  end

  # the case was that cookie_jar was not initialized
  # when headers are already being constructed
  it 'prepare cookies override' do
    url = "https://prepare_cookies_override.com"
    stub_request(:any, url).to_return { |request| { body: json_response, headers: request.headers } }

    class RedifinedCookieRequest < Apir::Request
      def some_condition
        true
      end

      def some_cookie
        HTTP::Cookie.new(
          name:   'cookie_name',
          value:  'cookie_value',
          domain: '.prepare_cookies_override.com',
          path:   '/'
        )
      end

      def prepare_cookies
        if some_condition
          @cookie_jar.add(some_cookie)
        end
        @cookie_jar
      end
    end

    request = RedifinedCookieRequest.new(url)

    request.post!
    expect(request.raw_response.cookies).to include('cookie_name' => 'cookie_value')
  end
end
