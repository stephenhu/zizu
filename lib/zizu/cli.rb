module Zizu

  class Cli

    REPOSITORY = "bootstrap-haml"
    IGNORE     = [ "layout.haml", "navbar.haml", "footer.haml" ]

    def login_github

      if @github.nil?

        @login     = ENV["ZIZU_GIT_LOGIN"] || nil
        @password  = ENV["ZIZU_GIT_PASSWORD"] || nil

        if @login.nil? or @password.nil?
          puts "please set env variables"
          exit
        end

        @github = Github.new( login:@login, password:@password )

        if @github.nil?
          puts "please set env variables"
          exit
        end

      end

    end

    #
    # zizu create NAME
    #
    #   1.  fork skeleton repository from github
    #   2.  clone repository to local
    #
    def create(name)

      if File.directory?(name)

        puts "directory already exists, init aborted"
        return

      else

        # fork github project

        login_github

        # TODO check for existence
        # TODO make atomic
        response = @github.repos.forks.create( "stephenhu", REPOSITORY )

        @user     = response[:owner][:login]

        if response.success?

          response = @github.repos.edit( @user, REPOSITORY, :name => name )
          @ssh_url = response[:git_url]

          r = %x[git clone #{@ssh_url} #{name}]

          puts r

        else
          puts "fork failed, aborting"
          exit
        end

      end

      puts "creating directory #{name}..."
            
    end

    def compile(ignore=[])

      puts ignore

      basedir = "."

      haml_files = Dir.glob("*.haml")

      puts haml_files

    end

  end

end

z = Zizu::Cli.new
z.compile

