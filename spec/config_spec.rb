require 'spec_helper' 

describe Cia::Config do

  class MockProxy
    attr_accessor :config

    def fetch(key)
      "abc"
    end
  end

  before(:each) do
    ENV.stub(:[]).with('RACK_ENV').and_return('test')
  end

  context 'loading' do

    it 'should load the yaml file specified in the path' do
      config = Cia::Config.new(:proxy => MockProxy.new, :path => 'spec/fixtures/cia.yaml')
      config.path = 'spec/fixtures/cia.yaml'
      config.load!
      config.connection.should == {:host=>"test.testing.co.uk"}
    end

    it 'should load a yaml file from a default location if it exists' do
      File.stub(:exists?).with('config/cia.yaml').and_return(true)
      YAML.stub(:load_file).with('config/cia.yaml').and_return(test: {a: 1})
      config = Cia::Config.new(:proxy => MockProxy.new)
      config.load!
      config.data.should == {a: 1} 
    end

  end

  context 'delegation' do

    it 'should delegate the proxy fetch method' do
      config = Cia::Config.new(:proxy => MockProxy.new, :path => 'spec/fixtures/cia.yaml')
      config.fetch("blah").should == "abc"
    end

  end

  context 'data' do

    it 'should allow the keys of the data hash to be methods' do
      config = Cia::Config.new(:proxy => MockProxy.new, :path => 'spec/fixtures/cia.yaml')
      config.data = {a: 1, b: 2}
      config.a.should == 1
      config.b.should == 2
    end

    it 'should raise an error if the keys of the data hash do not exist' do
      config = Cia::Config.new(:proxy => MockProxy.new, :path => 'spec/fixtures/cia.yaml')
      config.data = {a: 1, b: 2}
      lambda do
        config.c.should == 1
      end.should raise_error(NoMethodError)
    end 
 
  end
  
end
