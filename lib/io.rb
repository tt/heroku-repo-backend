class IO
  def self.join(mapping={})
    reads = mapping.keys

    while reads.length > 0
      (inputs, _, _) = IO.select(reads)

      inputs.each do |input|
        if input.eof?
          reads.delete(input)
          break
        end

        bytes = input.read_nonblock(1024)

        output = mapping.fetch(input)
        output.write bytes
      end
    end
  end
end
