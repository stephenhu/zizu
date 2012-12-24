module Zizu

  class GithubLib

    attr_accessor :api

    def initialize
      login
    end


    def login
                                                                                  
      if @api.nil?                                                           
 
        @login     = ENV["ZIZU_GIT_LOGIN"] || Rgit::Lib.config["user.email"]
        @password  = ENV["ZIZU_GIT_PASSWORD"] ||
          ask("git password: ") { |q| q.echo = "*" }
                                                                     
        if @login.nil? or @password.nil?                                        
          CmdLine.fatal("please set git config variable user.name")
        end

        @api = Github.new( login:@login, password:@password )
                                                                                  
        puts("login failed") if @api.nil?                           

      end

    end

    def fork( user, repo )

      unless fork_exists?("#{user}/#{repo}")

        response = @api.repos.forks.create( user, repo )

        return true if response.succeed?

      end

      return false

    end

    def fork_exists?(full_name)

      response = @api.repos.list( :user => @login )

      response.each do |r|

        user, repo = r[:full_name].split("/")
        get_r = @api.repos.get( user, repo )

        return true if get_r[:parent][:full_name] == full_name

      end

    end

  end

end

