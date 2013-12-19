require 'atelier/action_dsl'

describe Atelier::ActionDSL do

  class ActionClass
    include Atelier::ActionDSL
  end

  before(:all) { @action = ActionClass.new }
  subject { @action }

  describe 'attributes' do
    [
      :synopsis,
      :description
    ].each do |attr_name|
      describe "##{attr_name}" do
        value = "This is the #{attr_name} value"
        before { @action.send(attr_name, value) }

        its(attr_name) { should == value }
      end
    end
  end

  describe '#block' do
    before(:all) do
      @action = ActionClass.new
      @action.send(:block) { :expected_result }
    end
    subject { @action.instance_eval { @proc } }

    it { should be_a Proc }
    its(:call) { should == :expected_result }
  end

end
