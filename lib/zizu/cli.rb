module Zizu

  class CLI < Thor

    REPOSITORY = "bootstrap-haml"
    EXCLUDES   = [ "layout.haml", "navbar.haml", "footer.haml" ]

    #
    # zizu create NAME
    #
    #   1.  fork skeleton repository from github
    #   2.  clone repository to local
    #
    desc( "create NAME", "create site skeleton" )
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

          puts "bootstrap-haml repository forked:"
          puts "#{@ssh_url}"

          r = %x[git clone #{@ssh_url} #{name}]

          puts r

        else
          puts "fork failed, aborting operation"
          exit
        end

      end

    end

    desc( "compile", "compile .haml files to .html" )
    method_option :exclude, :aliases => "-x", :type => :string,
      :required => false, :desc => "files to exclude from compilation, " +
      "use comma separate multiple files"
    method_option :output, :aliases => "-o", :type => :string,
      :required => false, :desc => "output path for compiled files"
    def compile

      excludes  = check_exclusions(options[:exclude])
      dir       = create_directory(options[:output])
        
      basedir = "."

      haml_files = Dir.glob("*.haml")

      haml_files.each do |f|

        if excludes.include?(f)
          next
        else

          init_templates
          html = render(f)

          f = File.open( dir + f.chomp(".haml") + ".html", "w" )
          f.write(html)
          f.close

        end

      end

    end

    no_tasks do

      def check_exclusions(excludes_str)

        if excludes_str.nil?
          return EXCLUDES
        else

           user_excludes = excludes_str.split(",").each { |e| e.strip! }
           user_excludes = user_excludes + EXCLUDES
           user_excludes.uniq!
           return user_excludes

        end

      end

      def create_directory(name)
        puts name
        if name.nil?
          return ""
        else

          Dir.mkdir(name) unless File.directory?(name)
          return "#{name}/"

        end
                                                                            
      end

      def login_github                                                            
                                                                                  
        if @github.nil?                                                           
  # TODO use github global config parameters                                             
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

      def init_templates

        @layout = Tilt.new("layout.haml")
        @navbar = Tilt.new("navbar.haml")
        @footer = Tilt.new("footer.haml")

      end

      def render(template)

        if !template.nil?
          return @layout.render { Tilt.new(template).render }
        end

      end

    end

  end

end

