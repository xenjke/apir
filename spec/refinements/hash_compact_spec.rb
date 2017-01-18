# frozen_string_literal: true
require 'spec_helper'

describe 'Hash' do

  it '#compact' do
    expect({ key_1: 1, key_2: nil }.compact).to eq(key_1: 1)
  end

  it '#compact!' do
    h = { key_1: 1, key_2: nil }
    h.compact!
    expect(h).to eq(key_1: 1)
  end
end