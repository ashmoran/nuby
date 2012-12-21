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

      # Not sure what do do about the Rubyism here
      describe "brt" do
        let(:fixcode) {
          [ :const, comparison_operand, :const, 8, :brt, :const, 100, :print, :const, 200, :print ]
        }

        context "operand true" do
          let(:comparison_operand) { true }
          specify { expect(output).to be == "200" }
        end

        context "operand truthy" do
          let(:comparison_operand) { 123 }
          specify { expect(output).to be == "200" }
        end

        context "operand false" do
          let(:comparison_operand) { false }
          specify { expect(output).to be == "100\n200" }
        end

        context "operand nil" do
          let(:comparison_operand) { nil }
          specify { expect(output).to be == "100\n200" }
        end
      end

      # Not sure what do do about the Rubyism here
      describe "brf" do
        let(:fixcode) {
          [ :const, comparison_operand, :const, 8, :brf, :const, 100, :print, :const, 200, :print ]
        }

        context "operand true" do
          let(:comparison_operand) { true }
          specify { expect(output).to be == "100\n200" }
        end

        context "operand truthy" do
          let(:comparison_operand) { 123 }
          specify { expect(output).to be == "100\n200" }
        end

        context "operand false" do
          let(:comparison_operand) { false }
          specify { expect(output).to be == "200" }
        end

        context "operand nil" do
          let(:comparison_operand) { nil }
          specify { expect(output).to be == "200" }
        end
      end

      describe "gload/gstore" do
        let(:fixcode) {
          [
            :const,   100,
            :gstore,    0,
            :const,   200,
            :gstore,    1,
            :const,   101,
            :gstore,    0,
            :gload,     1,
            :print,
            :gload,     0,
            :print
          ]
        }

        specify { expect(output).to be == "200\n101" }
      end

      describe "print" do
        let(:fixcode) { [ :const, 100, :print, :const, 200, :print ] }
        specify { expect(output).to be == "100\n200" }
      end

      describe "nil" do
        describe "printing" do
          let(:fixcode) { [ :nil, :print ] }
          specify { expect(output).to be == "" }
        end

        describe "branching" do
          let(:fixcode) {
            [ :nil, :const, 7, :brf, :const, 100, :print, :const, 200, :print ]
          }
          specify { expect(output).to be == "200" }
        end
      end

      describe "pop" do
        let(:fixcode) { [ :const, 100, :const, 200, :pop, :print ] }
        specify { expect(output).to be == "100" }
      end

      describe "halt" do
        let(:fixcode) { [ :const, 100, :print, :halt, :const, 200, :print ] }
        specify { expect(output).to be == "100" }
      end
    end
  end
end