module Zizu

  class GithubLib

    attr_accessor :api

    def initialize
      login
    end


    def login

      config = Rgit::Lib.config

      if Zizu::USER == config["user.name"]
        Zizu::fatal("cannot fork a project you own, aborting")
      end

      if @api.nil?                                                           
 
        @login     = ENV["ZIZU_GIT_LOGIN"] || config["user.email"]
        @password  = ENV["ZIZU_GIT_PASSWORD"] ||
          ask("git password: ") { |q| q.echo = "*" }
        puts @login
        puts @password
                                                                     
        if @login.nil? or @password.nil?
          Zizu::fatal("please set git config variable user.name")
        end

        @api = Github.new( login:@login, password:@password )

        if @api.nil?
          Zizu::fatal("login failed")
        end

      end

    end

    def fork( user, repo )

      unless fork_exists?("#{user}/#{repo}")

        response = @api.repos.forks.create( user, repo )

        if response.success?
          Zizu::success("repository forked to: #{response[:git_url]}")
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
            Zizu::fatal(
              "repository has already been forked: #{get_r[:git_url]}")
            return true
          end

        else
          Zizu::fatal("Error: #{get_r.status}")
          Zizu::fatal(get_r.body)
        end

      end

      return false

    end

    def set_repository_name( repository, new_name )

      response = @api.repos.edit( @login, repository, :name => new_name )

      if response.success?
        Zizu::success("Repository successfully renamed to #{name}")
        Zizu::success(response[:git_url])
        return true
      else
        Zizu::fatal("GithubLib Error: #{response.status}")
      end

    end
 
  end

end

