module Xls
  module Importer

    # add validation
    def parse_wierd_input_to_array(input)
      input.split("\n").map do |item|
        item[2..-2].split(",\"").map do |item|
          item[0..-2]
        end
      end
    end

  end
end