class Goodall
  class Writer
    def initialize(file_path)
      @documentation_file = File.new(file_path, "w")
    end

    def close
      @documentation_file.close
    end

    def write(str)
      @documentation_file.puts str
    end
  end
end