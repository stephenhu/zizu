module Zizu

  class CLI < Thor

    desc( "create NAME", "create site skeleton" )
    method_option :fork, :aliases => "-f", :type => :boolean,
      :default => false, :required => false, :desc => "fork repo"
    def create(name)

      if File.directory?(name)
        Zizu::fatal("directory already exists, init aborted")
      else

        if options[:fork]
          fork(name)
        else
          create_skeleton(name)  
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

      unless options[:output].nil?
        dir = create_directory(options[:output])
      end

      basedir = "."

      haml_files = Dir.glob("*.haml")

      init_templates

      haml_files.each do |f|

        if excludes.include?(f)
          next
        else

          html      = haml_to_html(f)

          if dir.nil?
            html_name = f.chomp(".haml") + ".html"
          else
            html_name = dir + f.chomp(".haml") + ".html"
          end

          f = File.open( html_name, "w" )
          f.write(html)
          f.close

          Zizu::success("created #{html_name}")

        end

      end

      unless dir.nil?

        FileUtils.cp_r( "scripts", dir )
        Zizu::success("copying scripts directory")

        FileUtils.cp_r( "styles", dir )
        Zizu::success("copying styles directory")

        FileUtils.cp_r( "images", dir )
        Zizu::success("copying images directory")

      end
 
    end

    desc( "test", "deploy static files locally for testing")
    def test

      get_rack
      get_bootstrap

      Zizu::info("run the 'rackup' command to start the server locally")

    end

    desc( "deploy", "deploy static files to production" )
    method_option :target, :aliases => "-t", :required => false
    def deploy

      g = GithubLib.new

      latest = g.get_latest_commit()

      tree = g.get_tree(latest)
      g.download_files(tree)

    end

    no_tasks do

      def fork(name)

        g = GithubLib.new    

        # TODO make atomic
        git_url = g.fork( USER, REPOSITORY )

        unless git_url.nil?

          new_url = g.set_repository_name( REPOSITORY, name )

          if g.check_exists?(name)
            # TODO retry if it doesn't exist since this is asynch
            if Gitlib.clone( new_url, name )
              Zizu::success("repository cloned to local")
            else

              Zizu::fatal("unable clone remote repository")
              g.delete_repository(REPOSITORY)

            end

          else
            Zizu::fatal("repository rename failed, aborting operation")
            g.delete_repository(REPOSITORY)
          end

        else
          Zizu::fatal("fork failed, aborting operation")
        end

      end

      def get_rack

        configru = File.join( File.dirname(__FILE__), "config.ru" )
        FileUtils.cp( configru, "." ) unless File.exists?("./config.ru")

        Zizu::success("rackup configuration (config.ru) installed")

      end

      def get_bootstrap

        bootstrap = open(BOOTSTRAP)

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

      def create_skeleton(name)

        dirs = [ "images", "styles", "scripts", "conf" ]

        dirs.each do |d|
          create_directory( "#{name}/#{d}")
        end

        # copy from github or store locally?  if no network?
        # TODO how about a reverse html to haml?

        g = GithubLib.new

        latest = g.get_latest_commit()

        tree = g.get_tree(latest)
        g.download_files( tree, name )

      end

      def create_directory(name)

        if name.nil?
          Zizu::fatal("no directory name specified")
        else

          FileUtils.mkdir_p(name) unless File.directory?(name)
          Zizu::success("#{name} directory created")

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

