require 'spec_helper'

describe Consul do
  it 'has a version number' do
    expect(Consul::VERSION).not_to be nil
  end
end
