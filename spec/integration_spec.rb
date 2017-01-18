# frozen_string_literal: true
require 'spec_helper'
require 'webmock/rspec'
require 'apir'

WebMock.disable!

describe 'extending class with apir' do
  before(:all) do
    WebMock.enable!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after(:all) do
    WebMock.allow_net_connect!
    WebMock.disable!
  end

  describe 'with a module' do

    it 'provides class functions' do

    end

  end

end

describe 'logging' do

  it 'log request url' do

  end

  it 'request cookies' do

  end

  it 'request headers' do

  end

  it 'request curl' do

  end

  it 'request response code' do

  end

  it 'response time' do

  end

  it 'response cookie' do

  end


end