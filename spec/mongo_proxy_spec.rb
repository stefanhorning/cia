require 'spec_helper' 

describe Glass::MongoProxy do

   let(:subject){
     
     
     collection = mock
     collection.stub(:find_one)
     
     config = mock
     config.stub(:host).and_return("anothertesthost")

     mg = Glass::MongoProxy.new
     mg.stub(:connect!)
     mg.stub(:close)
     mg.stub(:config).and_return(config)
     mg.stub(:collection).and_return(collection)
     mg.stub(:roles).and_return(["anothertestrole"])
     mg
   }

   
  

  it 'should return the host specific mongo object if it exists' do
    subject.config.stub(:host).and_return("testhost")
    subject.collection.should_receive(:find_one).with("host" => "testhost", 
                                            "role" => {"$exists" => false}, 
                                            "testkey" => {"$exists" => true}).and_return({"host" => "testhost", 
                                                                                          "role" => "testrole", 
                                                                                          "testkey" => "abcd"})
    subject.fetch("testkey").should == "abcd"
  end

  it 'should return the role specific mongo object if it exists' do
    subject.collection.should_receive(:find_one).with("host" => {"$exists" => false}, 
                                                    "role" => "testrole", 
                                                    "testkey" => {"$exists" => true}).and_return({"role" => "testrole", 
                                                                                                  "testkey" => "efgh"})
    subject.stub(:roles).and_return(["testrole"])
    subject.fetch("testkey").should == "efgh"
  end

  it 'should return the global specific mongo object' do
    subject.collection.should_receive(:find_one).with("host" => {"$exists" => false}, 
                                                      "role" =>  {"$exists" => false}, 
                                                      "testkey" => {"$exists" => true}).and_return({"testkey" => "ijkl"})

    subject.fetch("testkey").should == "ijkl"
  end

  context 'Manager' do
    
    let(:subject){
   
       man = Glass::MongoProxy.new.manager
       man.mongo_config.stub(:collection).and_return(mock)
       man
     }

    context "global keys" do

      it 'should update and save an existing global key' do
        subject.mongo_config.stub(:global_key).with("testkey").and_return({"_id" => 'abcdefg', "testkey" => 123})
        subject.mongo_config.collection.should_receive(:save).with({"_id" => 'abcdefg', "testkey" => 456})
        subject.set_global_key("testkey", 456)
      end

      it 'should create and save a non-existing global key' do
        subject.mongo_config.stub(:global_key).with("testkey")
        subject.mongo_config.collection.should_receive(:save).with({"testkey" => 456})
        subject.set_global_key("testkey", 456)
      end

    end

    context "role keys" do

      it 'should update and save an existing global key' do
        subject.mongo_config.stub(:role_key).with("testrole","testkey").and_return({"_id" => 'abcdefg', "role" => "testrole", "testkey" => 123})
        subject.mongo_config.collection.should_receive(:save).with({"_id" => 'abcdefg', "role" => "testrole", "testkey" => 456})
        subject.set_role_key("testrole","testkey", 456)
      end

      it 'should create and save a non-existing global key' do
        subject.mongo_config.stub(:role_key).with("testrole","testkey")
        subject.mongo_config.collection.should_receive(:save).with({"role" => "testrole", "testkey" => 456})
        subject.set_role_key("testrole","testkey", 456)
      end

    end

    context "host keys" do

      it 'should update and save an existing global key' do
        subject.mongo_config.stub(:host_key).with("testhost","testkey").and_return({"_id" => 'abcdefg', "host" => "testhost", "testkey" => 123})
        subject.mongo_config.collection.should_receive(:save).with({"_id" => 'abcdefg', "host" => "testhost", "testkey" => 456})
        subject.set_host_key("testhost","testkey", 456)
      end

      it 'should create and save a non-existing global key' do
        subject.mongo_config.stub(:host_key).with("testhost","testkey")
        subject.mongo_config.collection.should_receive(:save).with({"host" => "testhost", "testkey" => 456})
        subject.set_host_key("testhost","testkey", 456)
      end

    end


    



  end

end

