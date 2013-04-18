require 'spec_helper'

module Glass

  describe Base do

    let(:subject){
      b = Base.new
      b.stub(:connect!)
      b.stub(:close)
      b.stub(:host_key)
      b.stub(:global_key)
      b.stub(:role_key)
      b.stub(:roles).and_return(["testrole1", "testrole2"])
      config = mock
      config.stub(:host => 'testhost')
      b.config = config
      b
    }

    context 'connections' do
      
      it 'should call connect and close on each fetch' do
        subject.should_receive(:connect!) do
          subject.should_receive(:close).once
        end
        subject.fetch("testkey")
      end

    end

    context 'fetch' do
  
      it 'should call the host_key with the host then the role key for each role and finally the global_key' do
        subject.should_receive(:host_key).with("testhost", "testkey") do
          subject.should_receive(:role_key).with("testrole1", "testkey") do
            subject.should_receive(:role_key).with("testrole2", "testkey") do
              subject.should_receive(:global_key).with("testkey").and_return(nil)
            end.and_return(nil)
          end.and_return(nil)
        end.and_return(nil)

        subject.fetch("testkey")
      end

      it 'should return the host_key if the result is not nil and not make subsequent calls' do

        subject.should_receive(:host_key).with("testhost", "testkey") do
          subject.should_receive(:role_key).with("testrole1", "testkey").never
          #subsequent expectations will never be set using this nested should_receive
        end.and_return({"host" => "testhost" ,"testkey" => 123})

        subject.fetch("testkey").should == 123
      end

      it 'should return the role_key if the result is not nil and not make subsequent calls' do

        subject.should_receive(:host_key).with("testhost", "testkey") do
          subject.should_receive(:role_key).with("testrole1", "testkey") do
            subject.should_receive(:role_key).with("testrole2", "testkey") do
              subject.should_receive(:global_key).with("testkey").never
            end.and_return({"role" => "testrole2", "testkey" => "yep"})
          end.and_return(nil)
        end.and_return(nil)

        subject.fetch("testkey").should == "yep"
      end

      it 'should return the global_key if the result is not nil and previus results are nil' do

        subject.should_receive(:host_key).with("testhost", "testkey") do
          subject.should_receive(:role_key).with("testrole1", "testkey") do
            subject.should_receive(:role_key).with("testrole2", "testkey") do
              subject.should_receive(:global_key).with("testkey").and_return({"testkey" => 789})
            end.and_return(nil)
          end.and_return(nil)
        end.and_return(nil)

        subject.fetch("testkey").should == 789
      end

    end

    context 'fetch!' do

      it 'should raise an error if the result is nil' do
        subject.should_receive(:fetch).with("testkey").and_return(nil)
        lambda do
          subject.fetch!("testkey")
        end.should raise_error(Glass::NoConfigurationError,"no configuration found for testkey")
      end

      it 'should not raise an error if the result is not nil' do
        subject.should_receive(:fetch).with("testkey").and_return("123")
        lambda do
          subject.fetch!("testkey")
        end.should_not raise_error(Glass::NoConfigurationError,"no configuration found for testkey")
      end
       

    end
  end

end
