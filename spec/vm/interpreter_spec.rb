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

      describe "iadd" do
        let(:fixcode) { [ :iconst, 1, :iconst, 2, :iadd, :print ] }
        specify { expect(output).to be == "3" }
      end

      describe "isub" do
        let(:fixcode) { [ :iconst, 150, :iconst, 25, :isub, :print ] }
        specify { expect(output).to be == "125" }
      end

      describe "imul" do
        let(:fixcode) { [ :iconst, 7, :iconst, 8, :imul, :print ] }
        specify { expect(output).to be == "56" }
      end

      describe "ilt" do
        context "a < b" do
          let(:fixcode) { [ :iconst, 29, :iconst, 30, :ilt, :print ] }
          specify { expect(output).to be == "true" }
        end

        context "a = b" do
          let(:fixcode) { [ :iconst, 30, :iconst, 30, :ilt, :print ] }
          specify { expect(output).to be == "false" }
        end

        context "a > b" do
          let(:fixcode) { [ :iconst, 31, :iconst, 30, :ilt, :print ] }
          specify { expect(output).to be == "false" }
        end
      end

      describe "ieq" do
        context "a < b" do
          let(:fixcode) { [ :iconst, 29, :iconst, 30, :ieq, :print ] }
          specify { expect(output).to be == "false" }
        end

        context "a = b" do
          let(:fixcode) { [ :iconst, 30, :iconst, 30, :ieq, :print ] }
          specify { expect(output).to be == "true" }
        end

        context "a > b" do
          let(:fixcode) { [ :iconst, 31, :iconst, 30, :ieq, :print ] }
          specify { expect(output).to be == "false" }
        end
      end

      describe "print" do
        let(:fixcode) { [ :iconst, 123, :print ] }
        specify { expect(output).to be == "123" }
      end
    end
  end
end