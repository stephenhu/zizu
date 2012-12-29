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
          puts "please set git config variable user.name".red
          exit
        end

        @api = Github.new( login:@login, password:@password )

        if @api.nil?
          puts "login failed".red
          exit
        end

      end

    end

    def fork( user, repo )

      unless fork_exists?("#{user}/#{repo}")

        response = @api.repos.forks.create( user, repo )

        if response.success?
          puts "repository forked to: #{response[:git_url]}".green
          return true
        end

      end

      return false

    end

    def fork_exists?(full_name)

      response = @api.repos.list( :user => @login )

      response.each do |r|

        user, repo = r[:full_name].split("/")
        get_r = @api.repos.get( user, repo )

        if get_r.success?

          if get_r[:fork] and get_r[:parent][:full_name] == full_name
            puts "repository has already been forked: #{get_r[:git_url]}".red
            return true
          end

        else
          puts "Error: #{get_r.status}".red
          puts get_r.body.yellow
          exit
        end

      end

      return false

    end

    def set_repository_name( repository, new_name )

      response = @api.repos.edit( @login, repository, :name => new_name )

      if response.success?
        puts "Repository successfully renamed to #{name}".green
        puts response[:git_url].green
        return true
      else
        puts "GithubLib Error: #{response.status}".red
        return false
      end

    end
 
  end

end

