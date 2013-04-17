require 'spec_helper' 

describe Glass::Config do

  context 'loading' do

    it 'should load the yaml file specified in the path' do
      config = Glass::Config.new
      config.path = 'spec/config/glass.yaml'
      config.load! 
    end

    it 'should load a yaml file from a default location if it exists' do
      File.stub(:exists?).with('config/glass.yaml').and_return(true)
      YAML.stub(:load_file).with('config/glass.yaml').and_return({a: 1})
      config = Glass::Config.new
      config.load!
      config.data.should == {a: 1} 
    end

  end

  context 'data' do

    it 'should allow the keys of the data hash to be methods' do
      config = Glass::Config.new
      config.data = {a: 1, b: 2}
      config.a.should == 1
      config.b.should == 2
    end

    it 'should raise an error if the keys of the data hash do not exist' do
      config = Glass::Config.new
      config.data = {a: 1, b: 2}
      lambda do
        config.c.should == 1
      end.should raise_error(NoMethodError)
    end 
 
  end
  
end
