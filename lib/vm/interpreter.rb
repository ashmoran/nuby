module Nuby
  module VM
    class Interpreter
      INSTR_IADD    = 1
      INSTR_ICONST  = 18
      INSTR_PRINT   = 27

      def initialize(options)
        @code       = options[:fixcode]
        @output_io  = options[:output_io]

        @operands   = [ ]
      end

      def exec
        run_cpu
      end

      def run_cpu
        ip = 0
        instruction = @code[ip]

        while ip < @code.length
          ip += 1

          case instruction
          when INSTR_IADD
            left, right = @operands.pop(2)
            @operands.push(left + right)
          when INSTR_ICONST
            @operands.push(@code[ip])
            ip += 1
          when INSTR_PRINT
            @output_io.puts(@operands.pop)
            ip += 1
          else
            raise "Unknown instruction code: #{instruction}"
          end

          instruction = @code[ip]
        end
      end
    end
  end
end