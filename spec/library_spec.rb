require 'rask/library'

describe Rask::Library do

  describe '#initialize' do
    context 'without any parameters' do
      specify { expect { Rask::Library.new() {} }.to raise_error ArgumentError }
    end

    context 'providing name' do
      name = :LibName
      subject { Rask::Library.new(name) {} }

      its(:name) { should == name }
    end
  end

end