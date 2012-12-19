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

      context "print" do
        let(:fixcode) { [ 18, 123, 27 ] }

        specify {
          interpreter.exec
          expect(output).to be == "123"
        }
      end

      context "add and print" do
        let(:fixcode) { [ 18, 1, 18, 2, 1, 27 ] }

        specify {
          interpreter.exec
          expect(output).to be == "3"
        }
      end
    end
  end
end