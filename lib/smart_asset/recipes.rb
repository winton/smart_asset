require File.join File.dirname(__FILE__),'..','smart_asset'
Capistrano::Configuration.instance(:must_exist).load do
  namespace :smart_asset do

    desc 'Precompile assets for deploys'
    task :precompile do
      destination = SmartAsset.load_config(Dir.pwd) && SmartAsset.dest
      run_locally "smart_asset"
      return unless scm == :git
      run_locally "git ls-files -d #{destination['javascripts']} #{destination['stylesheets']} | xargs git rm"
      run_locally "git add #{destination['javascripts']} #{destination['stylesheets']}"
      run_locally "git commit -m 'autocommit: smart_asset'"
    end
  end
end