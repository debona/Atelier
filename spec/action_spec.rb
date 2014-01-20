require 'spec_helper'

require 'atelier/action'

describe Atelier::Action do

  describe '#initialize' do
    proc = Proc.new { :action_block }
    subject { Atelier::Action.new(:action_name) { block(&proc) } }
    its(:name) { should == :action_name }
    its(:proc) { should == proc }
  end

end
