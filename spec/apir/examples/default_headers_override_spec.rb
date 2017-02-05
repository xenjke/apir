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

    stub_request(:post, url).
      with(headers: { 'Cookie': 'auth=session; auth_cookie=some_uid' }).
      to_return(:status => 200, :body => "success", :headers => { 'Set-Cookie' => 'auth=session' })

    stub_request(:get, url).
      with(:headers => { 'Cookie' => 'auth_cookie=some_uid' }).
      to_return(:status => 200, :body => "", :headers => { 'Set-Cookie' => 'auth=session' })
    
    class RedifinedCookieRequest < Apir::Request
      def some_condition
        true
      end

      def some_cookie
        HTTP::Cookie.new(
          name:   'auth_cookie',
          value:  'some_uid',
          domain: 'prepare_cookies_override.com',
          path:   '/'
        )
      end
    end

    request        = RedifinedCookieRequest.new(url)
    second_request = RedifinedCookieRequest.new(url)

    request.cookie_jar << HTTP::Cookie.new(
      name:   'auth_cookie',
      value:  'some_uid',
      domain: '.prepare_cookies_override.com',
      path:   '/')

    expect(request.cookies).to eq({ 'auth_cookie' => 'some_uid' })
    second_request.cookie_jar = request.cookie_jar
    expect(second_request.cookies).to eq({ 'auth_cookie' => 'some_uid' })

    request.get!
    expect(request.raw_response.cookies).to include('auth' => 'session')

    second_request.cookie_jar = request.raw_response.cookie_jar
    expect(second_request.cookies).to eq({ 'auth_cookie' => 'some_uid', 'auth' => 'session' })

    second_request.post!
    expect(second_request.raw_response.body).to eq('success')
  end
end
