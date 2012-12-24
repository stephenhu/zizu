module Zizu

  module CmdLine

    def fatal(msg)
      puts msg.red
      exit
    end

    def success(msg)
      puts msg.green
    end

  end

end

