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
        Interpreter.new(fixcode: fixcode, output_io: output_io)
      }

      describe "iadd" do
        let(:fixcode) { [ 18, 1, 18, 2, 1, 27 ] }

        specify {
          interpreter.exec
          expect(output).to be == "3"
        }
      end

      describe "isub" do
        let(:fixcode) { [ 18, 150, 18, 25, 2, 27 ] }

        specify {
          interpreter.exec
          expect(output).to be == "125"
        }
      end

      describe "imul" do
        let(:fixcode) { [ 18, 7, 18, 8, 3, 27 ] }

        specify {
          interpreter.exec
          expect(output).to be == "56"
        }
      end

      describe "ilt" do
        context "a < b" do
          let(:fixcode) { [ 18, 29, 18, 30, 4, 27 ] }

          specify {
            interpreter.exec
            expect(output).to be == "true"
          }
        end

        context "a = b" do
          let(:fixcode) { [ 18, 30, 18, 30, 4, 27 ] }

          specify {
            interpreter.exec
            expect(output).to be == "false"
          }
        end

        context "a > b" do
          let(:fixcode) { [ 18, 31, 18, 30, 4, 27 ] }

          specify {
            interpreter.exec
            expect(output).to be == "false"
          }
        end
      end

      describe "print" do
        let(:fixcode) { [ 18, 123, 27 ] }

        specify {
          interpreter.exec
          expect(output).to be == "123"
        }
      end
    end
  end
end