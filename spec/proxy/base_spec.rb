require 'spec_helper'

module Cia
  module Proxy
    describe Base do

      let(:subject){
        b = Base.new
        b.stub(:connect!)
        b.stub(:close)
        b.stub(:host_value)
        b.stub(:global_value)
        b.stub(:role_value)
        b.stub(:roles).and_return(["testrole1", "testrole2"])
        config = double
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
    
        it 'should call the host_value with the host then the role key for each role and finally the global_value' do
          subject.should_receive(:host_value).with("testhost", "testkey") do
            subject.should_receive(:role_value).with("testrole1", "testkey") do
              subject.should_receive(:role_value).with("testrole2", "testkey") do
                subject.should_receive(:global_value).with("testkey").and_return(nil)
              end.and_return(nil)
            end.and_return(nil)
          end.and_return(nil)

          subject.fetch("testkey")
        end

        it 'should return the host_value if the result is not nil and not make subsequent calls' do

          subject.should_receive(:host_value).with("testhost", "testkey") do
            subject.should_receive(:role_value).with("testrole1", "testkey").never
            #subsequent expectations will never be set using this nested should_receive
          end.and_return(123)

          subject.fetch("testkey").should == 123
        end

        it 'should return the role_value if the result is not nil and not make subsequent calls' do

          subject.should_receive(:host_value).with("testhost", "testkey") do
            subject.should_receive(:role_value).with("testrole1", "testkey") do
              subject.should_receive(:role_value).with("testrole2", "testkey") do
                subject.should_receive(:global_value).with("testkey").never
              end.and_return("yep")
            end.and_return(nil)
          end.and_return(nil)

          subject.fetch("testkey").should == "yep"
        end

        it 'should return the global_value if the result is not nil and previus results are nil' do

          subject.should_receive(:host_value).with("testhost", "testkey") do
            subject.should_receive(:role_value).with("testrole1", "testkey") do
              subject.should_receive(:role_value).with("testrole2", "testkey") do
                subject.should_receive(:global_value).with("testkey").and_return(789)
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
          end.should raise_error(Cia::NoConfigurationError,"no configuration found for testkey")
        end

        it 'should not raise an error if the result is not nil' do
          subject.should_receive(:fetch).with("testkey").and_return("123")
          lambda do
            subject.fetch!("testkey")
          end.should_not raise_error(Cia::NoConfigurationError,"no configuration found for testkey")
        end
         

      end
    end
  end
end
