require 'spec_helper'

require 'vm/interpreter'

module Nuby
  module VM
    describe Interpreter do
      let(:output_io) { StringIO.new }
      def output
        output_io.rewind
        output_io.read.chomp
      end

      let(:compiled_fixcode) {
        fixcode.map { |code|
          code.is_a?(Symbol) ? Fixcode::INSTR.const_get(code.to_s.upcase) : code
        }
      }

      subject(:interpreter) {
        Interpreter.new(fixcode: compiled_fixcode, output_io: output_io)
      }

      before(:each) do
        interpreter.exec
      end

      describe "add" do
        let(:fixcode) { [ :const, 1, :const, 2, :add, :print ] }
        specify { expect(output).to be == "3" }
      end

      describe "sub" do
        let(:fixcode) { [ :const, 150, :const, 25, :sub, :print ] }
        specify { expect(output).to be == "125" }
      end

      describe "mul" do
        let(:fixcode) { [ :const, 7, :const, 8, :mul, :print ] }
        specify { expect(output).to be == "56" }
      end

      describe "lt" do
        context "a < b" do
          let(:fixcode) { [ :const, 29, :const, 30, :lt, :print ] }
          specify { expect(output).to be == "true" }
        end

        context "a = b" do
          let(:fixcode) { [ :const, 30, :const, 30, :lt, :print ] }
          specify { expect(output).to be == "false" }
        end

        context "a > b" do
          let(:fixcode) { [ :const, 31, :const, 30, :lt, :print ] }
          specify { expect(output).to be == "false" }
        end
      end

      describe "eq" do
        context "a < b" do
          let(:fixcode) { [ :const, 29, :const, 30, :eq, :print ] }
          specify { expect(output).to be == "false" }
        end

        context "a = b" do
          let(:fixcode) { [ :const, 30, :const, 30, :eq, :print ] }
          specify { expect(output).to be == "true" }
        end

        context "a > b" do
          let(:fixcode) { [ :const, 31, :const, 30, :eq, :print ] }
          specify { expect(output).to be == "false" }
        end
      end

      describe "br" do
        let(:fixcode) { [ :const, 6, :br, :const, 100, :print, :const, 200, :print ] }
        specify { expect(output).to be == "200" }
      end

      describe "print" do
        let(:fixcode) { [ :const, 123, :print ] }
        specify { expect(output).to be == "123" }
      end
    end
  end
end