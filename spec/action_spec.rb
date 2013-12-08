require 'rask/action'

describe Rask::Action do

  describe '#initialize' do
    proc = Proc.new { :action_block }
    subject { Rask::Action.new(:action_name) { block(&proc) } }
    its(:name) { should == :action_name }
    its(:proc) { should == proc }
  end

end
