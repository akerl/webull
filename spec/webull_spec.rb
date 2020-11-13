require 'spec_helper'

describe Webull do
  describe '#new' do
    it 'creates Account objects' do
      expect(
        Webull.new(tokens: 1, udid: 1)
      ).to be_an_instance_of Webull::Account
    end
  end
end
