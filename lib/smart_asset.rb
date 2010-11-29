require File.dirname(__FILE__) + '/smart_asset/gems'

SmartAsset::Gems.require(:lib)

require 'fileutils'
require 'time'

$:.unshift File.dirname(__FILE__) + '/smart_asset'

require 'version'

class SmartAsset
  class <<self
    
    attr_reader :config, :dest, :root
    
    CLOSURE_COMPILER = File.expand_path(File.dirname(__FILE__) + '/../bin/closure_compiler.jar')
    YUI_COMPRESSOR = File.expand_path(File.dirname(__FILE__) + '/../bin/yui_compressor.jar')
    
    def binary(root, relative_config='config/assets.yml')
      load_config root, relative_config
      compress 'javascripts', 'js'
      compress 'stylesheets', 'css'
    end
    
    def compress(type, ext)
      FileUtils.mkdir_p @dest
      @config[type].each do |relative_dir, packages|
        prefix = relative_dir.gsub('/', '_')
        dir = File.expand_path("#{@root}/#{relative_dir}")
        packages.each do |package, files|
          create_package = false
          compressed = {}
          if files
            files.each do |file|
              if File.exists?(source = "#{dir}/#{file}.#{ext}")
                modified = `cd #{@root} && git log --pretty=format:%cd -n 1 --date=iso #{relative_dir}/#{file}.#{ext}`
                next if modified.empty?
                modified = Time.parse(modified).utc.strftime("%Y%m%d%H%M%S")
                unless File.exists?(destination = "#{@dest}/#{modified}_#{prefix}_#{file}.#{ext}")
                  create_package = true
                  Dir["#{@dest}/*_#{prefix}_#{file}.#{ext}"].each do |old|
                    FileUtils.rm old
                  end
                  puts "\nCompressing #{source}..."
                  if ext == 'js'
                    `java -jar #{CLOSURE_COMPILER} --js #{source} --js_output_file #{destination} --warning_level QUIET`
                  elsif ext == 'css'
                    `java -jar #{YUI_COMPRESSOR} #{source} -o #{destination}`
                  end
                end
                compressed[destination] = modified
              end
            end
          end
          if modified = compressed.values.compact.sort.last
            package = "#{@dest}/#{modified}_#{package}.#{ext}"
            if create_package || !File.exists?(package)
              data = compressed.keys.collect do |file|
                File.read file
              end
              File.open(package, 'w') { |f| f.write(data.join) }
            end
          end
        end
      end
    end
    
    def load_config(root, relative_config='config/assets.yml')
      @root = File.expand_path(root)
      @config = YAML::load(File.read("#{@root}/#{relative_config}"))
      @dest = File.expand_path("#{@root}/#{@config['to']}")
    end
  end
end

require "adapters/rails#{Rails.version[0..0]}" if defined?(Rails)
require "adapters/sinatra" if defined?(Sinatra)