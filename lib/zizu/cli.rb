module Zizu

  class CLI < Thor

    desc( "create NAME", "create site skeleton" )
    def create(name)

      if File.directory?(name)
        Zizu::fatal("directory already exists, init aborted")
      else

        # fork github project

        g = GithubLib.new    

        # TODO make atomic
        if g.fork( Zizu::USER, Zizu::REPOSITORY )

          if g.set_repository_name( REPOSITORY, name )

            if Rgit::Lib.clone( @git_url, name )
              Zizu::success("repository cloned to local")
            else
              Zizu::fatal("unable clone remote repository")
            end

          end

        else
          Zizu::fatal("fork failed, aborting operation")
        end

      end

    end

    desc( "compile", "compile template files to .html" )
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

      init_templates

      haml_files.each do |f|

        if excludes.include?(f)
          next
        else

          html = haml_to_html(f)

          f = File.open( dir + f.chomp(".haml") + ".html", "w" )
          f.write(html)
          f.close

        end

      end

    end

    desc( "test", "deploy static files locally for testing")
    def test

      get_rack
      get_bootstrap

      Zizu::info("run the 'rackup' command to start the server locally")

    end

    desc( "deploy", "deploy static files to production" )
    method_option :target, :aliases => "-t"
    def deploy

    end

    no_tasks do

      def get_rack

        configru = File.join( File.dirname(__FILE__), "config.ru" )
        FileUtils.cp( configru, "." ) unless File.exists?("./config.ru")

        Zizu::success("rackup configuration (config.ru) installed")

      end

      def get_bootstrap

        bootstrap = open(Zizu::BOOTSTRAP)

        Zip::ZipFile.open(bootstrap.path) do |z|

          z.each do |f|
            path = File.join( ".", f.name )
            FileUtils.mkdir_p(File.dirname(path))
            z.extract( f, path ) unless File.exist?(path)
          end

        end

        Zizu::success("bootstrap latest installed")

      end

      def get_dependencies

        # bootstrap

      end

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

        @layout = Tilt.new("layout.haml") if File.exists?("layout.haml")
        @navbar = Tilt.new("navbar.haml") if File.exists?("navbar.haml")
        @footer = Tilt.new("footer.haml") if File.exists?("footer.haml")

      end

      def haml_to_html(template)

        unless @layout.nil?
          html = @layout.render { Tilt.new(template).render }
          return html
        end

        Zizu::fatal("layout.haml template is missing, aborting compile")

      end

    end

  end

end

