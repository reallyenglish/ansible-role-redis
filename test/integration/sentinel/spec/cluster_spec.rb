require 'spec_helper'

describe server(:master) do
  describe redis("ping") do
    it 'should ping server' do
      expect(result).to eq('PONG')
    end
  end
end

describe server(:slave1) do
  describe redis("ping") do
    it 'should ping server' do
      expect(result).to eq('PONG')
    end
  end
end

describe server(:slave2) do
  describe redis("ping") do
    it 'should ping server' do
      expect(result).to eq('PONG')
    end
  end
end
