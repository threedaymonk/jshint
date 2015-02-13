require 'yaml'
require "multi_json"

module Jshint
  # Configuration object containing JSHint lint settings
  class Configuration

    # @return [Hash] the configration options
    attr_reader :options

    # Initializes our configuration object
    #
    # @param path [String] The path to the config file
    def initialize(path = nil)
      @path = path || default_config_path
      @options = parse_config
    end

    # Returns the value of the options Hash if one exists
    #
    # @param key [Symbol]
    # @return The value of the of the options Hash at the passed in key
    def [](key)
      options["options"][key.to_s]
    end

    # Returns a Hash of global variables if one exists
    #
    # @example
    #   {
    #     "$" => true,
    #     jQuery => true,
    #     angular => true
    #   }
    #
    # @return [Hash, nil] The key value pairs or nil
    def global_variables
      options["options"]["globals"]
    end

    # Returns a Hash of options to be used by JSHint
    #
    # See http://jshint.com/docs/options/ for more config options
    #
    # @example
    #   {
    #     "eqeqeq" => true,
    #     "indent" => 2
    #   }
    # @return [Hash, nil] The key value pairs of options or nil
    def lint_options
      @lint_options ||= options["options"].reject { |key| key == "globals" }
    end

    # Returns the list of files that JSHint should lint over relatives to the Application root
    #
    # @example
    #   [
    #     'angular/controllers/*.js',
    #     'angular/services/*.js'
    #   ]
    #
    # @return [Array<String>] An Array of String files paths
    def files
      options["files"]
    end

    def excluded_search_paths
      options.fetch("exclude_paths", [])
    end

    def search_paths
      default_search_paths - excluded_search_paths
    end

    def default_search_paths
      [
        'app/assets/javascripts',
        'vendor/assets/javascripts',
        'lib/assets/javascripts'
      ]
    end

    private

    def parse_config
      raw = File.open(@path, 'r:UTF-8').read
      if @path =~ /\.jshintrc\z/
        default_config.merge("options" => MultiJson.load(raw))
      else
        default_config.merge(YAML.load(raw))
      end
    end

    def default_config
      { "files" => ["**/*.js"] }
    end

    def default_config_path
      root = defined?(Rails) ? Rails.root : Dir.pwd
      files = ['config/jshint.yml', '.jshintrc'].map { |p| File.join(root, p) }
      files.find { |f| File.exist?(f) } || files.first
    end
  end
end
