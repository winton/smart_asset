# require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

# if FrameworkFixture.rails == '<3'
#   describe 'Rails 2' do

#     include Rack::Test::Methods

#     def app
#       FrameworkFixture.app.call
#     end
    
#     before(:all) do
#       build = "#{$root}/spec/fixtures/builds/rails2"
#       setup_adapter_build("#{build}/public")
#       SmartAsset.binary(build) if Rails.env == 'production'
#     end
  
#     it "should have a pulse" do
#       get "/pulse"
#       last_response.body.should == '1'
#     end
    
#     it "should execute helpers correctly" do
#       get "/test"
#       equals_output(Rails.env, last_response.body)
#     end
#   end
# end