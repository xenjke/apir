require 'spec_helper'
require 'webmock/rspec'
require 'apir'

describe 'authorisation override' do

  it 'auth is passed' do
    auth    = {login: 'mamky', password: 'vkinovodil'}
    request = Apir::Request.new('https://tested.tested', authorisation: auth)
    expect(request.authorisation).to eq(auth)
  end

  it 'auth is overriden' do
    auth                  = {login: 'mamky', password: 'vkinovodil'}
    request               = Apir::Request.new('https://tested.tested', authorisation: auth)
    override_auth         = {login: 'mamka', password: 'vyhuhol'}
    request.authorisation = override_auth
    expect(request.authorisation).to eq(override_auth)
  end

end