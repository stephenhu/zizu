module Zizu

  class GithubLib

    attr_accessor :api

    def initialize
      login
    end


    def login

      if @api.nil?                                                           
 
        config = Gitlib.config

        @login     = ENV["ZIZU_GIT_LOGIN"] || config["user.name"]

        if @login == USER
          Zizu::fatal("cannot fork a project that you own, aborting")
        end

        @password  = ENV["ZIZU_GIT_PASSWORD"] ||
          ask("git password: ") { |q| q.echo = "*" }

        if @login.nil? or @password.nil?
          Zizu::fatal("please set git config variable user.name or env variable ZIZU_GIT_LOGIN.")
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
          return response[:git_url]
        end

      end

      return nil 

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

    def check_exists?(repo)

      response = @api.repos.get( @login, repo )

      if response.success?
        return true
      else
        return false
      end

    end

    def set_repository_name( repository, new_name )

      response = @api.repos.edit( @login, repository, :name => new_name )

      if response.success?
        Zizu::success("Repository successfully renamed to #{new_name}")
        Zizu::success(response[:git_url])
        return response[:git_url] 
      else
        Zizu::fatal("GithubLib Error: #{response.status}")
        return nil
      end

    end

    def delete_repository(name)

      puts @login
      puts "rollback"

      #response = @api.repos.delete( @login, name )

    end

    def get_latest_commit

      response = @api.repos.commits.list( USER, REPOSITORY )

      if response.success?
        return response[0][:sha]
      else
        fatal("unable to retrieve latest commit hash")
      end

    end

    def get_tree(id)

      #latest = get_latest_commit

      response = @api.git_data.trees.get( USER, REPOSITORY, id )

      if response.success?
        return response[:tree]
      else
        fatal("unable to retrieve tree for #{id}")
      end

    end

    def download_files( tree, dir=nil )

      tree.each do |t|

        if t["type"] == "tree"

          if dir.nil?
            new_path = t["path"]
          else
            new_path = "#{dir}/#{t["path"]}"
          end

          FileUtils.mkdir_p(new_path)
          download_files( get_tree(t["sha"]), new_path )
          next

        else

          data = open(t["url"])
          json = JSON.parse(data.read())

          unless json["content"].nil?

            if dir.nil?
              f = File.open( t["path"], "w" )
            else
              f = File.open( "#{dir}/#{t["path"]}", "w" )
            end

            contents = Base64.decode64(json["content"])
            f.write(contents)
            f.close

          end

        end

      end

    end

  end

end

