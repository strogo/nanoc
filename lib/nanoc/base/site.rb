module Nanoc
  class Site

    DEFAULT_CONFIG = {
      :output_dir   => 'output',
      :eruby_engine => 'erb',
      :data_source  => 'filesystem'
    }

    attr_reader :config,  :page_defaults
    attr_reader :compiler, :creator
    attr_reader :pages, :layouts, :templates

    # Creating a Site object

    def self.in_site_dir?
      return false unless File.directory?('content')
      return false unless File.directory?('layouts')
      return false unless File.directory?('lib')
      return false unless File.directory?('tasks')
      return false unless File.directory?('templates')
      return false unless File.exist?('config.yaml')
      return false unless File.exist?('meta.yaml')
      return false unless File.exist?('Rakefile')

      true
    end

    def self.from_cwd
      in_site_dir? ? new : nil
    end

    def initialize
      # Load configuration
      @config = DEFAULT_CONFIG.merge(YAML.load_file_and_clean('config.yaml'))

      # Create compiler
      @compiler = Nanoc::Compiler.new

      # Load page defaults
      @page_defaults = YAML.load_file_and_clean('meta.yaml')
    end

    # Data source stuff

    def register_data_source(name, klass)
      @data_sources ||= {}
      @data_sources[name.to_sym] = klass
    end

    def load_data
      if @data_source.nil?
        # Find data source class
        data_source_class = @data_sources[@config[:data_source].to_sym]
        if data_source_class.nil?
          $stderr.puts "ERROR: Unrecognised data source: #{@config[:data_source]}"
          exit(1)
        end

        # Create data source
        @data_source = data_source_class.new(self)
      end

      # Start data source
      @data_source.up

      # Load data
      @pages      = @data_source.pages.map { |p| Page.new(p, self) } if @pages.nil?
      @layouts    = @data_source.layouts   if @layouts.nil?
      @templates  = @data_source.templates if @templates.nil?

      # Stop data source
      @data_source.down
    end

    # Compiling

    def compile!
      load_data
      @compiler.run!(@pages, @page_defaults, @config)
    end

    # Creating

    def create_page
    end

    def create_template
    end

    def create_layout
    end

    def create_database
    end

  end
end