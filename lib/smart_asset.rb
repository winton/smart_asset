require 'digest'
require 'fileutils'
require 'time'
require 'yaml'

require "change"

$:.unshift File.dirname(__FILE__)

require 'smart_asset/helper'

class SmartAsset
  class <<self
    
    attr_accessor :append_random, :asset_host, :asset_counter, :cache, :config, :dest, :env, :envs, :pub, :root, :sources
    
    def binary(root, relative_config=nil)
      load_config root, relative_config
      compress 'javascripts'
      compress 'stylesheets'
    end
    
    def compress(type)
      dest = @dest[type]
      dir = "#{@pub}/#{@sources[type]}"
      ext = ext_from_type(type)
      packages = []
      time_cache = {}

      change = Change.new(dir)
      change.d
      states = change.send(:states)
      
      FileUtils.mkdir_p dest
      
      (@config[type] || {}).each do |package, files|
        next if ENV['PACKAGE'] && ENV['PACKAGE'] != package
        if files
          # Generate file hashes
          hashes = files.inject([]) do |array, file|
            path = "#{file}.#{ext}"
            if states[path]
              array << "#{states[path][:size]}#{states[path][:hash]}"
            end
            array
          end
          next if hashes.empty?
          
          # Modified hash
          hash = Digest::SHA1.hexdigest(hashes.join)[0..7]
          
          # Package path
          package = "#{dest}/#{hash}_#{package}.#{ext}"
          
          # If package file exists
          if File.exists?(package)
            packages << package
          else
            data = []
            
            # Join files in package
            files.each do |file|
              if File.exists?(source = "#{dir}/#{file}.#{ext}")
                data << File.read(source)
              end
            end
            
            # Don't create new compressed file if no data
            data = data.join("\n")
            next if data.strip.empty?
            
            # Compress joined files
            tmp = "#{dest}/tmp.#{ext}"
            File.open(tmp, 'w') { |f| f.write(data) }
            puts "\nCreating #{package}..."
            warning = ENV['WARN'] ? " -v" : nil
            unless @bin
              @bin = Dir.chdir(@root) { `npm bin` }
              @bin = File.exists?(@bin) ? "#{@bin}/" : nil
            end
            if ext == 'js'
              cmd = "#{@bin}uglifyjs --output #{package}#{warning} -nc #{tmp}"
            elsif ext == 'css'
              cmd = "#{@bin}cleancss #{tmp} -o #{package}"
            end
            puts cmd if ENV['DEBUG']
            `#{cmd}`
            FileUtils.rm(tmp) unless ENV['DEBUG']
            
            # Fix YUI compression issue
            if ext == 'css'
              if RUBY_PLATFORM.downcase.include?('darwin')
                `sed -i '' 's/ and(/ and (/g' #{package}`
              else
                `sed -i 's/ and(/ and (/g' #{package}`
              end
            end
            
            # Package created
            packages << package
          end
        end
      end
      
      # Remove old/unused packages
      (Dir["#{dest}/#{"[^_]"*8}_*.#{ext}"] - packages).each do |path|
        FileUtils.rm path
      end
      
      # Delete legacy files
      Dir["#{dest}/*.yml", "#{dest}/#{"[0-9]"*14}_*.{css,js}"].each do |path|
        FileUtils.rm path
      end
    end
    
    def load_config(root, relative_config=nil)
      relative_config ||= 'config/assets.yml'
      @root = File.expand_path(root)

      return unless File.file?("#{@root}/#{relative_config}")

      @cache = nil
      @config = YAML::load(File.read("#{@root}/#{relative_config}"))
      
      # Default values
      if @config['append_random'].nil?
        @config['append_random'] = {}
      end
      if @config['append_random'].is_a?(::Hash) && @config['append_random']['development'].nil?
        @config['append_random']['development'] = true
      end
      
      @config['asset_host_count'] ||= 4
      @config['asset_host'] ||= ActionController::Base.asset_host rescue nil
      @config['environments'] ||= %w(production)
      @config['public'] ||= 'public'
      
      @config['destination'] ||= {}
      @config['destination']['javascripts'] ||= 'javascripts/packaged'
      @config['destination']['stylesheets'] ||= 'stylesheets/packaged'
      
      @config['sources'] ||= {}
      @config['sources']['javascripts'] ||= "javascripts"
      @config['sources']['stylesheets'] ||= "stylesheets"
      
      # Convert from asset packager syntax
      %w(javascripts stylesheets).each do |type|
        if @config[type].respond_to?(:pop)
          @config[type] = @config[type].inject({}) do |hash, package|
            hash.merge! package
          end
        end
      end
      
      # Class variables
      @append_random = 
        if @config['append_random'].is_a?(::Hash)
          @config['append_random'][@env]
        else
          @config['append_random']
        end
      
      @asset_host = @config['asset_host']
      @envs = @config['environments']
      @sources = @config['sources']
      
      @pub = File.expand_path("#{@root}/#{@config['public']}")
      @dest = %w(javascripts stylesheets).inject({}) do |hash, type|
        hash[type] = "#{@pub}/#{@config['destination'][type]}"
        hash
      end
    end
    
    def paths(type, match)
      match = match.to_s
      
      @cache ||= {}
      @cache[type] ||= {}
      
      if @cache[type][match]
        return @cache[type][match]
      end
      
      dest = @dest[type]
      ext = ext_from_type type
      
      if @envs.include?(@env.to_s)
        @cache[type][match] =
          if result = Dir["#{dest}/#{"[^_]"*8}_#{match}.#{ext}"].first
            [ result.gsub(@pub, '') ]
          else
            []
          end
      elsif @config && @config[type]
        result = @config[type].collect do |package, files|
          if package.to_s == match
            files.collect do |file|
              file = "/#{@sources[type]}/#{file}.#{ext}"
              file if File.exists?("#{@pub}/#{file}")
            end
          end
        end
        result.flatten.compact.uniq
      end
    end
    
    def prepend_asset_host(path)
      if @asset_host.respond_to?(:keys)
        host = @asset_host[@env.to_s]
      else
        host = @asset_host
      end
      
      if host    
        if !@asset_counter || @asset_counter == @config['asset_host_count']
          @asset_counter = 0
        end
      
        count = @asset_counter.to_s
        @asset_counter += 1
      
        host.gsub('%d', count) + path
      else
        path
      end
    end
    
    private
    
    def ext_from_type(type)
      case type
      when 'javascripts' then
        'js'
      when 'stylesheets' then
        'css'
      end
    end
  end
end

require "smart_asset/adapters/rails#{Rails.version[0..0]}" if defined?(Rails)
require "smart_asset/adapters/sinatra" if defined?(Sinatra)
require "smart_asset/adapters/stasis" if defined?(Stasis)