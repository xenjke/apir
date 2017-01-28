require 'spec_helper'
require 'webmock/rspec'
WebMock.disable!

require 'apir'

describe 'Request logging' do
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

  it 'via override' do
    url = "https://logging.com"
    stub_request(:any, url).to_return { |request| { body: json_response, headers: request.headers } }

    class RedifinedRequest < Apir::Request
      def log(string, log_type)
        puts "#{log_type}: #{string}"
      end

      def with_logging #<-- overridden one
        log(url, ">> #{@type}-request")
        log(request_cookies_string, '>> cookies-jar') unless @cookie_jar.cookies.empty?
        yield if block_given?
        log(response_cookies_string, '<< cookies') unless raw_response.cookies.empty?
        log("#{@raw_response.code}. #{@time_taken} ms.", '<< response')
      end
    end
    request         = RedifinedRequest.new(url)
    request.headers = { oh_wow: true }
    request.cookie_jar << HTTP::Cookie.new(name:   'referrer', value: 'test',
                                           domain: '.logging.com',
                                           path:   '/')
    request.post!
  end
end
