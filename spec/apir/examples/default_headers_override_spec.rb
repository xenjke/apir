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
end
