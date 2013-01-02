module Zizu

  class CLI < Thor

    #USER       = "stephenhu"
    #REPOSITORY = "bootstrap-haml"
    #EXCLUDES   = [ "layout.haml", "navbar.haml", "footer.haml" ]

    desc( "create NAME", "creates site skeleton" )
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

    desc( "stage", "deploy file locally" )
    method_option :port, :port => "-p", :type => :numeric, :required => false,
      :desc => "port number to serve pages"
    def stage

      configru = File.join( File.dirname(__FILE__), "config.ru" )
      FileUtils.cp( configru, "." )

      port_option = options[:port].nil? ? "" : " -p #{options[:port]}"

      #stdin, stdout, stderr = Open3.popen3("rackup" + port_option)

      #puts stderr.read
      #puts stdout.read

    end

    desc( "deploy", "deploy static files" )
    method_option :target, :aliases => "-t"
    def deploy

    end

    no_tasks do

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

