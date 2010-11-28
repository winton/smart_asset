require File.dirname(__FILE__) + '/smart_asset/gems'

SmartAsset::Gems.require(:lib)

$:.unshift File.dirname(__FILE__) + '/smart_asset'

require 'version'

class SmartAsset
  class <<self
    
    attr_reader :config, :dest, :root
    
    def compress(root, relative_config='config/assets.yml')
      load_config root, relative_config
      FileUtils.mkdir_p @dest
      @config['javascripts'].each do |relative_dir, packages|
        prefix = relative_dir.gsub('/', '_')
        dir = File.expand_path("#{@root}/#{relative_dir}")
        packages.each do |package, javascripts|
          javascripts.each do |js|
            puts "#{dir}/#{js}.js"
            if File.exists?("#{dir}/#{js}.js")
              modified = `cd #{@root} && git log --pretty=format:%cd -n 1 --date=iso #{relative_dir}/#{js}.js`
              puts modified.inspect
              #`java -jar compiler.jar --js hello.js --js_output_file hello-compiled.js`
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