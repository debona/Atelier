require 'rask/action_dsl'

describe Rask::ActionDSL do

  before(:all) { @action = Object.new.extend Rask::ActionDSL }
  subject { @action }

  describe 'attributes' do
    [
      :synopsis,
      :description
    ].each do |attr_name|
      describe "##{attr_name}" do
        value = "This is the #{attr_name} value"
        before { @action.send("#{attr_name}=", value) }

        its(attr_name) { should == value }
      end
    end
  end

  describe '#block' do
    before(:all) do
      @action = Object.new.extend Rask::ActionDSL
      @action.send(:block) { :expected_result }
    end
    subject { @action.instance_eval { @proc } }

    it { should be_a Proc }
    its(:call) { should == :expected_result }
  end

end
