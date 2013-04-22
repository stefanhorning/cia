require 'spec_helper' 

describe Glass::Proxy::Mongo do

  def mock_mongo!

    hosts_collection = mock
    hosts_collection.stub(:find_one)

    global_collection = mock
    global_collection.stub(:find_one)

    roles_collection = mock
    roles_collection.stub(:find_one)

    mc = mock
    mc.stub(:close)
    mc.stub(:[]).with("config_db").and_return({"hosts" => hosts_collection, "roles" => roles_collection, "global" => global_collection})
    ::Mongo::MongoClient.stub(:new).and_return(mc)

  end

  
  let(:subject){

     mock_mongo!
     
     config = mock
     config.stub(:host).and_return("anothertesthost")
     config.stub(:connection).and_return(:host => 'mockmongo')
     config.stub(:db).and_return("config_db")

     mg = Glass::Proxy::Mongo.new
     mg.stub(:config).and_return(config)
     mg.stub(:roles).and_return(["anothertestrole"])
     
     mg

  }

  it 'should return the host specific mongo object if it exists' do
    subject.connect!
    subject.config.stub(:host).and_return("testhost")
    subject.db["hosts"].stub(:find_one).with("_id" => "testhost").and_return({"host" => "testhost", "testkey" => "abcd"})
    subject.fetch("testkey").should == "abcd"
  end

  it 'should return the role specific mongo object if it exists' do
    subject.connect!
    subject.db["roles"].should_receive(:find_one).with("_id" => "testrole").and_return({"_id" => "testrole", "testkey" => "efgh"})
    subject.stub(:roles).and_return(["testrole"])
    subject.fetch("testkey").should == "efgh"
  end

  it 'should return the global specific mongo object' do
    subject.connect!
    subject.db["global"].should_receive(:find_one).with("_id" => "testkey").and_return({"_id" => "testkey", "value" => "ijkl"})
    subject.fetch("testkey").should == "ijkl"
  end

  context 'Manager' do
    
    let(:manager){
   
       subject.manager
       
     }

    context "global keys" do

      it 'should update and save an existing global key' do
        manager.proxy.stub(:global_obj).with("testkey").and_return({"_id" => 'testkey', "value" => 123})
        manager.proxy.db["global"].should_receive(:save).with({"_id" => 'testkey', "value" => 456})
        manager.set_global_value("testkey", 456)
      end

      it 'should create and save a non-existing global key' do
        manager.proxy.stub(:global_obj).with("testkey")
        manager.proxy.db["global"].should_receive(:save).with({"_id" => "testkey", "value" => 456})
        manager.set_global_value("testkey", 456)
      end

    end

    context "role keys" do

      it 'should update and save an existing global key' do
        manager.proxy.stub(:role_obj).with("testrole").and_return({"_id" => 'testrole', "testkey" => 123})

        manager.proxy.db["roles"].should_receive(:save).with({"_id" => 'testrole', "testkey" => 456})
        manager.set_role_value("testrole","testkey", 456)
      end

      it 'should create and save a non-existing global key' do
        manager.proxy.stub(:role_obj).with("testrole")
        manager.proxy.db["roles"].should_receive(:save).with({"_id" => "testrole", "testkey" => 456})
        manager.set_role_value("testrole","testkey", 456)
      end

    end

    context "host keys" do

      it 'should update and save an existing global key' do
        manager.proxy.stub(:host_obj).with("testhost").and_return({"_id" => 'testhost', "testkey" => 123})
        manager.proxy.db["hosts"].should_receive(:save).with({"_id" => "testhost", "testkey" => 456})
        manager.set_host_value("testhost","testkey", 456)
      end

      it 'should create and save a non-existing global key' do
        manager.proxy.stub(:host_value).with("testhost","testkey")
        manager.proxy.db["hosts"].should_receive(:save).with({"_id" => "testhost", "testkey" => 456})
        manager.set_host_value("testhost","testkey", 456)
      end

    end


    



  end

end

