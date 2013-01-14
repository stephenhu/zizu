module Zizu

  module Gitlib 

    def self.cmd(str)

      stdin, stdout, stderr = Open3.popen3(str)

      err = stderr.read.chomp

      return { :stdout => stdout.read.chomp, :stderr => err,
        :status => err.length > 0 ? false : true }

    end

    def self.version

      r = cmd("git --version")
      tokens = r[:stdout].split(" ")
      return tokens[-1]

    end

    def self.config

      configs = Hash.new

      r = cmd("git config -l")

      if r[:status]

        # TODO windows and mac support
        params = r[:stdout].split("\n")

        params.each do |p|
          key, value = p.split("=")
          configs[key.strip] = value.strip
        end

        return configs

      else
        Zizu::fatal("command failed")
        return nil
      end

    end

    def self.clone( url, dest=nil )

      r = cmd("git clone #{url} #{dest}")

      if r[:status]
        Zizu::success(r[:stdout])
      else
        Zizu::fatal(r[:stderr])
      end

      return r[:status]

    end

  end

end

