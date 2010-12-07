require File.dirname(__FILE__) + '/smart_asset/gems'

SmartAsset::Gems.require(:lib)

require 'fileutils'
require 'time'
require 'yaml'

$:.unshift File.dirname(__FILE__)

require 'smart_asset/helper'
require 'smart_asset/version'

class SmartAsset
  class <<self
    
    attr_accessor :asset_host, :asset_counter, :cache, :config, :dest, :env, :envs, :pub, :root, :sources
    
    BIN = File.expand_path(File.dirname(__FILE__) + '/../bin')
    CLOSURE_COMPILER = BIN + '/closure_compiler.jar'
    YUI_COMPRESSOR = BIN + '/yui_compressor.jar'
    
    def binary(root, relative_config=nil)
      load_config root, relative_config
      compress 'javascripts'
      compress 'stylesheets'
    end
    
    def compress(type)
      dest = @dest[type]
      dir = "#{@pub}/#{@sources[type]}"
      ext = ext_from_type type
      FileUtils.mkdir_p dest
      (@config[type] || {}).each do |package, files|
        create_package = false
        compressed = {}
        if files
          files.each do |file|
            if File.exists?(source = "#{dir}/#{file}.#{ext}")
              modified = `cd #{@root} && git log --pretty=format:%cd -n 1 --date=iso #{@config['public']}/#{@sources[type]}/#{file}.#{ext}`
              if modified.strip.empty?
                modified = Time.now.utc.strftime("%Y%m%d%H%M%S")
              else
                modified = Time.parse(modified).utc.strftime("%Y%m%d%H%M%S")
              end
              file = file.to_s.gsub('/', '_')
              unless File.exists?(destination = "#{dest}/#{modified}_#{package}_#{file}.#{ext}")
                create_package = true
                Dir["#{dest}/*[0-9]_#{package}_#{file}.#{ext}"].each do |old|
                  FileUtils.rm old
                end
                puts "\nCompressing #{source}..."
                if ext == 'js'
                  warning = ENV['WARN'] ? nil : " --warning_level QUIET"
                  cmd = "java -jar #{CLOSURE_COMPILER} --js #{source} --js_output_file #{destination}#{warning}"
                elsif ext == 'css'
                  cmd = "java -jar #{YUI_COMPRESSOR} #{source} -o #{destination}"
                end
                puts cmd if ENV['DEBUG']
                `#{cmd}`
              end
              compressed[destination] = modified
            end
          end
          if modified = compressed.values.compact.sort.last
            old_packages = "#{dest}/*[0-9]_#{package}.#{ext}"
            package = "#{dest}/#{modified}_#{package}.#{ext}"
            if create_package || !File.exists?(package)
              Dir[old_packages].each do |old|
                FileUtils.rm old
              end
              data = compressed.keys.collect do |file|
                File.read file
              end
              File.open(package, 'w') { |f| f.write(data.join) }
            end
          end
        end
      end
    end
    
    def load_config(root, relative_config=nil)
      relative_config ||= 'config/assets.yml'
      @root = File.expand_path(root)
      @config = YAML::load(File.read("#{@root}/#{relative_config}"))
      
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
        match = match.gsub('/', '_')
        @cache[type][match] =
          if result = Dir["#{dest}/*_#{match}.#{ext}"].sort.last
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
          elsif files
            files.collect do |file|
              if file.to_s == match
                file = "/#{@sources[type]}/#{file}.#{ext}"
                file if File.exists?("#{@pub}/#{file}")
              end
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