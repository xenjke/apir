require 'spec_helper'
require 'webmock/rspec'
WebMock.disable!

require 'apir'

# it is always usefull to have some kind of
# config module or a singletone
module YourApiConfig
  # with some basic hostname and path
  # common for your API
  # useful to manage environments
  URL         = 'https://yourapi.com/_api'
  CREDENTIALS = { login: 'user', password: 'password' }
end

# each request to your API is a class
class AuthorisationRequest < ::Apir::Request
  # initialize with custom args
  # to be stored as class instance variables
  def initialize(**args)
    super("#{YourApiConfig::URL}/authorisation", args)
  end

  # prefer business functions
  def login_as(login, password)
    # some custom properties
    # for this request class
    @login    = login
    @password = password

    # let's say we authorise as post with form-data body
    self.body = { login: login, password: password }
    post!(:form_data)
  end

  # read responses as functions
  def authorised?
    # make sure not to create chains
    # like `response[:result][:authorisation][:status]`
    # create safe functions for each level of JSON
    # and fallback with `response[:result] || {}`
    response[:status] == 'AUTHORISED'
  end

  # this hook will be used to log
  # the authorisation status
  # on every request made
  def post_initialize
    "#{@login} is authorised" if authorised?
  end

end

describe AuthorisationRequest do
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

  it 'some basic assertions', :smoke_test do
    stub_request(:any, "#{YourApiConfig::URL}/authorisation").to_return { { body: json_response } }
    request = AuthorisationRequest.new
    request.login_as('user', 'password')
    # did we get the correct response?
    expect(request.raw_response.code).to eq 200
    # did we authorised?
    expect(request.authorised?).to be_truthy
    # assert incoming cookies
    expect(request.raw_response.cookies).to be_empty
  end

  it 'manage user agent if needed' do
    stub_request(:any, "#{YourApiConfig::URL}/authorisation").to_return { |request| { body: json_response, headers: request.headers } }
    request                        = AuthorisationRequest.new
    request.headers[:user_agent]   = 'Ham&Cheese'
    request.headers[:content_type] = 'text/html; charset=utf-8'
    request.get!
    expect(request.raw_response.headers[:user_agent]).to eq('Ham&Cheese')
    expect(request.raw_response.headers[:content_type]).to eq('text/html; charset=utf-8')
  end
end