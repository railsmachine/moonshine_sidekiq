require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class SidekiqManifest < Moonshine::Manifest::Rails
  include Moonshine::Sidekiq
end

describe "A manifest with the sidekiq plugin" do
  before do
    @manifest = SidekiqManifest.new
    @manifest.configure(:sidekiq => {}, :deploy_to => '/srv/app')
  end

  it "should be executable" do
    @manifest.should be_executable
  end

  describe "using the `sidekiq` recipe" do
    before do
      @manifest.sidekiq
    end

    it "should install the template" do
      sidekiq_file = @manifest.files["/etc/god/#{@manifest.configuration[:application]}-sidekiq.god"]['content']
      sidekiq_file.should_not be_nil
      sidekiq_file.should include("1.times do |num|")
      sidekiq_file.should include("w.group    = '#{@manifest.configuration[:application]}-sidekiq'")
      sidekiq_file.should include("w.name     = \"#{@manifest.configuration[:application]}-sidekiq")
    end
  end

  describe "configuring the `sidekiq` recipe" do
    before do
      @manifest.configure(:sidekiq => { :workers => 2})
      @manifest.sidekiq
    end
    
    it "should install the template with configuration" do
      sidekiq_file = @manifest.files["/etc/god/#{@manifest.configuration[:application]}-sidekiq.god"]['content']
      sidekiq_file.should_not be_nil
      sidekiq_file.should include("2.times do |num|")
    end
  end
end
