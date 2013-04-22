require 'spec_helper' 

describe Glass::Config do

  class MockProxy
    attr_accessor :config

    def fetch(key)
      "abc"
    end
  end

  context 'loading' do

    it 'should load the yaml file specified in the path' do
      config = Glass::Config.new(:proxy => MockProxy.new)
      config.path = 'spec/fixtures/glass.yaml'
      config.load!
      config.connection.should == {:host=>"test.testing.co.uk"}
      config.roles.should == ["testrole1", "testrole2"] 
    end

    it 'should load a yaml file from a default location if it exists' do
      File.stub(:exists?).with('config/glass.yaml').and_return(true)
      YAML.stub(:load_file).with('config/glass.yaml').and_return({a: 1})
      config = Glass::Config.new(:proxy => MockProxy.new)
      config.load!
      config.data.should == {a: 1} 
    end

  end

  context 'delegation' do

    it 'should delegate the proxy fetch method' do
      config = Glass::Config.new(:proxy => MockProxy.new)
      config.fetch("blah").should == "abc"
    end

  end

  context 'data' do

    it 'should allow the keys of the data hash to be methods' do
      config = Glass::Config.new(:proxy => MockProxy.new)
      config.data = {a: 1, b: 2}
      config.a.should == 1
      config.b.should == 2
    end

    it 'should raise an error if the keys of the data hash do not exist' do
      config = Glass::Config.new(:proxy => MockProxy.new)
      config.data = {a: 1, b: 2}
      lambda do
        config.c.should == 1
      end.should raise_error(NoMethodError)
    end 
 
  end
  
end
