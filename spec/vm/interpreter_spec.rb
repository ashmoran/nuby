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

      subject(:interpreter) {
        Interpreter.new(
          fixcode:    fixcode,
          constants:  constants,
          output_io:  output_io
        )
      }

      before(:each) do
        interpreter.exec
      end

      context "linear instructions (no functions defined)" do
        let(:constants) { [ ] }

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

        describe "mul" do
          let(:fixcode) { [ :const, 7, :const, 8, :mul, :print ] }
          specify { expect(output).to be == "56" }
        end

        describe "div" do
          let(:fixcode) { [ :const, 20, :const, 5, :div, :print ] }
          specify { expect(output).to be == "4" }
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

        describe "load/store" do
          context "main" do
            let(:fixcode) {
              [
                :const,   100,
                :store,    0,
                :const,   200,
                :store,    1,
                :const,   101,
                :store,    0,
                :load,     1,
                :print,
                :load,     0,
                :print
              ]
            }

            specify { expect(output).to be == "200\n101" }
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

      context "nested instructions (functions defined)" do
        describe "call" do
          describe "single (open) call" do
            let(:constants) { [ FunctionSymbol.new(name: "f", address: 5) ] }

            let(:fixcode) {
              [
                :call, 0,
                :const, 100,
                :print,
                :const, 200,
                :print
              ]
            }

            specify { expect(output).to be == "200" }
          end

          describe "single call and ret" do
            let(:constants) { [ FunctionSymbol.new(name: "f", address: 6) ] }

            let(:fixcode) {
              [
                :call, 0,
                :const, 100,
                :print,
                :halt,
                :const, 200,
                :print,
                :ret
              ]
            }

            specify { expect(output).to be == "200\n100" }
          end

          describe "double (open) call" do
            let(:constants) {
              [ FunctionSymbol.new(name: "f", address: 5), FunctionSymbol.new(name: "g", address: 10) ]
            }

            let(:fixcode) {
              [
                :call, 0,
                :const, 100,
                :print,
                :call, 1,
                :const, 200,
                :print,
                :const, 300,
                :print
              ]
            }

            specify { expect(output).to be == "300" }
          end

          describe "double call and ret" do
            let(:constants) {
              [ FunctionSymbol.new(name: "f", address: 6), FunctionSymbol.new(name: "g", address: 12) ]
            }

            let(:fixcode) {
              [
                :call, 0,
                :const, 100,
                :print,
                :halt,
                :call, 1,
                :const, 200,
                :print,
                :ret,
                :const, 300,
                :print,
                :ret
              ]
            }

            specify { expect(output).to be == "300\n200\n100" }
          end
        end

        describe "args" do
          context "single call" do
            let(:constants) {
              [ FunctionSymbol.new(name: "f", address: 6, num_args: 2) ]
            }

            let(:fixcode) {
              [
                :const, 100,
                :const, 200,
                :call, 0,
                :load, 0,
                :print,
                :load, 1,
                :print
              ]
            }

            specify { expect(output).to be == "100\n200" }
          end

          context "nested calls" do
            let(:constants) {
              [
                FunctionSymbol.new(name: "f", address: 7, num_args: 2),
                FunctionSymbol.new(name: "g", address: 22, num_args: 1)
              ]
            }

            let(:fixcode) {
              [
                :const, 10,
                :const, 20,
                :call,   0,
                :halt,
                :load,   0, # f()
                :load,   1,
                :add,
                :call,   1,
                :print,
                :load,   0,
                :print,
                :load,   1,
                :print,
                :ret,
                :load,   0, # g()
                :const,  4,
                :mul,
                :ret
              ]
            }

            specify { expect(output).to be == "120\n10\n20" }
          end
        end
      end
    end
  end
end