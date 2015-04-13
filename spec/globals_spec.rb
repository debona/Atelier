require 'spec_helper'

require 'atelier/globals'

describe :Globals do
  before(:all) { @app = Atelier::Application.instance }
  subject { @app }

  describe '.command' do
    it 'should redirect to the app load_root_command method' do
      @app.should_receive(:load_root_command).with(:name, {})
      command(:name, {}) {}
    end
  end
end
