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
        fatal("directory already exists, init aborted")
      else

        # fork github project

        g = GithubLib.new    

        # TODO make atomic
        fatal("fork failed") unless g.fork( "stephenhu", REPOSITORY )

        #@user = response[:owner][:login]

        if response.success?

          response = g.api.repos.edit( @login, REPOSITORY, :name => name )
          @git_url = response[:git_url]

          success("bootstrap-haml repository forked: #{@git_url}")

          r = Rgit::Lib.clone( @git_url, name )

          if r
            success("repository cloned to local")
          else
            fatal("unable clone remote repository")
          end

        else
          fatal("fork failed, aborting operation")
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

        if name.nil?
          return ""
        else

          Dir.mkdir(name) unless File.directory?(name)
          return "#{name}/"

        end
                                                                            
      end

      def init_templates

        @layout = Tilt.new("layout.haml")
        @navbar = Tilt.new("navbar.haml")
        @footer = Tilt.new("footer.haml")

      end

      def render(template)

        return
          @layout.render { Tilt.new(template).render } unless template.nil?

      end

      def success(msg)
        puts msg.green
      end

      def fatal(msg)
        puts msg.red
        exit
      end

    end

  end

end

