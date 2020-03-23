require 'spec_helper'

require 'atelier/application'
require 'atelier/composable'

describe Atelier::Composable do

  class CmdClass
    include Atelier::Composable

    def application
      @application ||= Atelier::Application.new
    end
  end

  subject { CmdClass.new }

  describe "#sub_commands_hash" do
    it 'is empty by default' do
      expect(subject.sub_commands_hash).to eq Hash[]
    end
  end

  describe "#sub_command_names" do
    it "returns the name of all subcommands" do
      subject.sub_commands_hash[:sub_cmd_name] = :a_command
      subject.sub_commands_hash[:another_sub_cmd_name] = :a_command
      expect(subject.sub_command_names).to match_array [:sub_cmd_name, :another_sub_cmd_name]
    end
  end

  describe "#sub_commands" do
    it "returns the subcommands" do
      subject.sub_commands_hash[:sub_cmd_name] = :a_command
      subject.sub_commands_hash[:another_sub_cmd_name] = :another_command
      expect(subject.sub_commands).to match_array [:a_command, :another_command]
    end
  end


  describe '#command' do
    it "adds the new command to sub_commands_hash" do
      new_command = nil
      expect {
        new_command = subject.command(:sub_cmd_name) {}
      }.to change {
        subject.sub_commands_hash.size
      }.from(0).to(1)
      expect(subject.sub_commands_hash[:sub_cmd_name]).to eq new_command
    end

    it 'does NOT trigger the run method' do
      expect(subject).to_not receive(:run)
      subject.command(:sub_cmd_name) {}
    end

    describe 'created sub_command' do
      let(:sub_command) { subject.command(:sub_cmd_name) {} }

      it { expect(sub_command).to be_a Atelier::Command }

      it { expect(sub_command.name).to eq :sub_cmd_name }

      it 'sub_command super_command equals the command' do
        expect(sub_command.super_command).to eq subject
      end
    end
  end

  describe '#load_command' do
    cmd_path = 'spec/fixtures/loaded.rb'

    before { subject.load_command(cmd_path) }

    it 'loads the command as a ruby file' do
      expect(TOPLEVEL_BINDING.eval('@loaded_properly')).to eq true
    end
  end
end
