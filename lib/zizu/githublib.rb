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
                                                                                  
        CmdLine.fatal("unable to login") if @api.nil?                           

      end

    end

  end

end

