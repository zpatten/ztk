################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################

require "spec_helper"

describe ZTK::DSL do

  subject {
    class DSLTest < ZTK::DSL::Base
    end

    DSLTest.new
  }

  before(:all) do
    $stdout = File.open("/dev/null", "w")
    $stderr = File.open("/dev/null", "w")
    $stdin = File.open("/dev/null", "r")
  end


  describe "class" do

    it "should be an instance of ZTK::DSL" do
      subject.should be_an_instance_of DSLTest
    end

  end

  describe "attributes" do

    it "should allow setting of an attribute via a block" do
      data = "Hello World @ #{Time.now.utc}"
      class DSLTest < ZTK::DSL::Base
        attribute :name
      end

      dsl_test = DSLTest.new do
        name "#{data}"
      end

      dsl_test.name.should == data
    end

    it "should allow setting of an attribute directly" do
      data = "Hello World @ #{Time.now.utc}"
      class DSLTest < ZTK::DSL::Base
        attribute :name
      end

      dsl_test = DSLTest.new
      dsl_test.name ="#{data}"

      dsl_test.name.should == data
    end

    it "should throw an exception when setting an invalid attribute" do
      data = "Hello World @ #{Time.now.utc}"
      class DSLTest < ZTK::DSL::Base
        attribute :name
      end

      lambda {
        dsl_test = DSLTest.new do
          thing "#{data}"
        end
      }.should raise_error
    end

  end

  describe "relations" do

    before(:each) do
      class Environment < ZTK::DSL::Base
        has_many :containers

        attribute :name
      end
      Environment.purge

      class Container < ZTK::DSL::Base
        belongs_to :environment

        attribute :name
      end
      Container.purge
    end

    describe "has_many" do

      it "can has_many via nesting" do
        env = Environment.new do
          name "environment"
          container do
            name "container0"
          end
          container do
            name "container1"
          end
          container do
            name "container2"
          end
        end

        env.name.should == "environment"
        env.containers.count.should == 3
        env.containers.each do |container|
          %w(container0 container1 container2).include?(container.name).should == true
          container.environment.should == env
          container.environment_id.should == env.id
        end
      end

      it "can has_many via direct object assignment" do
        env = Environment.new do
          name "environment"
        end
        con0 = Container.new do
          name "container0"
        end
        con1 = Container.new do
          name "container1"
        end
        con2 = Container.new do
          name "container2"
        end
        con0.environment = env
        con1.environment = env
        con2.environment = env

        env.name.should == "environment"
        env.containers.count.should == 3
        env.containers.each do |container|
          %w(container0 container1 container2).include?(container.name).should == true
          container.environment.should == env
          container.environment_id.should == env.id
        end
      end

      it "can has_many via direct object id assignment" do
        env = Environment.new do
          name "environment"
        end
        con0 = Container.new do
          name "container0"
        end
        con1 = Container.new do
          name "container1"
        end
        con2 = Container.new do
          name "container2"
        end
        con0.environment_id = env.id
        con1.environment_id = env.id
        con2.environment_id = env.id

        env.name.should == "environment"
        env.containers.count.should == 3
        env.containers.each do |container|
          %w(container0 container1 container2).include?(container.name).should == true
          container.environment.should == env
          container.environment_id.should == env.id
        end
      end

      # it "can has_many via direct object addition" do
      #   env = Environment.new do
      #     name "environment"
      #   end
      #   con0 = Container.new do
      #     name "container0"
      #   end
      #   con1 = Container.new do
      #     name "container1"
      #   end
      #   con2 = Container.new do
      #     name "container2"
      #   end
      #   env.containers << con0
      #   env.containers << con1
      #   env.containers << con2

      #   env.name.should == "environment"
      #   env.containers.count.should == 3
      #   env.containers.each do |container|
      #     %w(container0 container1 container2).include?(container.name).should == true
      #     container.environment.should == env
      #     container.environment_id.should == env.id
      #   end
      # end

    end

    describe "belongs_to" do
      it "can belong_to via nesting" do
        env = Environment.new do
          name "environment"
          container do
            name "container0"
          end
          container do
            name "container1"
          end
          container do
            name "container2"
          end
        end

        env.name.should == "environment"
        env.containers.count.should == 3
        env.containers.each do |container|
          %w(container0 container1 container2).include?(container.name).should == true
          container.environment.should == env
          container.environment_id.should == env.id
        end
      end

      it "can belong_to via direct assignment" do
        env = Environment.new do
          name "environment"
        end
        con0 = Container.new do
          name "container0"
          environment env
        end
        con1 = Container.new do
          name "container1"
          environment env
        end
        con2 = Container.new do
          name "container2"
          environment env
        end

        env.name.should == "environment"
        env.containers.count.should == 3
        env.containers.each do |container|
          %w(container0 container1 container2).include?(container.name).should == true
          container.environment.should == env
          container.environment_id.should == env.id
        end
      end

      it "can belong_to via direct object id assignment" do
        env = Environment.new do
          name "environment"
        end
        con0 = Container.new do
          name "container0"
          environment_id env.id
        end
        con1 = Container.new do
          name "container1"
          environment_id env.id
        end
        con2 = Container.new do
          name "container2"
          environment_id env.id
        end

        env.name.should == "environment"
        env.containers.count.should == 3
        env.containers.each do |container|
          %w(container0 container1 container2).include?(container.name).should == true
          container.environment.should == env
          container.environment_id.should == env.id
        end
      end

    end

  end

  describe "find" do

    before(:each) do
      class Environment < ZTK::DSL::Base
        has_many :containers

        attribute :name
      end
      Environment.purge

      class Container < ZTK::DSL::Base
        belongs_to :environment

        attribute :name
      end
      Container.purge
    end

    it "single id" do
      env = Environment.new do
        id :env0
        name "environment"

        $con0 = container do
          id :con0
          name "container0"
        end
        $con1 = container do
          id :con1
          name "container1"
        end
        $con2 = container do
          id :con2
          name "container2"
        end
      end
      Environment.find(:env0).first.should == env
      Container.find(:con0).first.should == $con0
      Container.find(:con1).first.should == $con1
      Container.find(:con2).first.should == $con2
    end

    it "multiple ids" do
      env = Environment.new do
        id :env0
        name "environment"

        $con0 = container do
          id :con0
          name "container0"
        end
        $con1 = container do
          id :con1
          name "container1"
        end
        $con2 = container do
          id :con2
          name "container2"
        end
      end
      Environment.find(:env0).first.should == env
      containers = Container.find([:con0, :con1, :con2])
      containers.count.should == 3
      containers.all? do |container|
        [:con0, :con1, :con2].include?(container.id)
      end
    end

  end

  describe "complex relations" do

    before(:each) do
      class Environment < ZTK::DSL::Base
        has_many :containers
        has_many :networks

        attribute :name
      end
      Environment.purge

      class Container < ZTK::DSL::Base
        belongs_to :environment
        belongs_to :network

        attribute :name
      end
      Container.purge

      class Network < ZTK::DSL::Base
        has_many :containers
        belongs_to :environment

        attribute :name
      end
      Network.purge
    end

    it "one parent, two children with interdependency, id assignment" do
      env = Environment.new do
        name "environment"

        network do
          id :net0
          name "network0"
        end
        network do
          id :net1
          name "network1"
        end

        container do
          id :con0
          name "container0"
          network_id :net0
        end
        container do
          id :con1
          name "container1"
          network_id :net0
        end
        container do
          id :con2
          name "container2"
          network_id :net1
        end
      end

      env.name.should == "environment"
      env.containers.count.should == 3
      env.containers.each do |container|
        %w(container0 container1 container2).include?(container.name).should == true
        container.environment.should == env
        container.environment_id.should == env.id
      end
      env.networks.each do |network|
        %w(network0 network1).include?(network.name).should == true
        network.environment.should == env
        network.environment_id.should == env.id
      end

      n0 = Network.find(:net0).first
      n0.containers.each do |container|
        %w(container0 container1).include?(container.name).should == true
        container.environment.should == env
        container.environment_id.should == env.id
      end

      n1 = Network.find(:net1).first
      n1.containers.each do |container|
        %w(container2).include?(container.name).should == true
        container.environment.should == env
        container.environment_id.should == env.id
      end
    end

    it "one parent, two children with interdependency, direct assignment" do
      env = Environment.new do
        name "environment"

        net0 = network do
          id :net0
          name "network0"
        end
        net1 = network do
          id :net1
          name "network1"
        end

        container do
          id :con0
          name "container0"
          network net0
        end
        container do
          id :con1
          name "container1"
          network net0
        end
        container do
          id :con2
          name "container2"
          network net1
        end
      end

      env.name.should == "environment"
      env.containers.count.should == 3
      env.containers.each do |container|
        %w(container0 container1 container2).include?(container.name).should == true
        container.environment.should == env
        container.environment_id.should == env.id
      end
      env.networks.each do |network|
        %w(network0 network1).include?(network.name).should == true
        network.environment.should == env
        network.environment_id.should == env.id
      end

      n0 = Network.find(:net0).first
      n0.containers.each do |container|
        %w(container0 container1).include?(container.name).should == true
        container.environment.should == env
        container.environment_id.should == env.id
      end

      n1 = Network.find(:net1).first
      n1.containers.each do |container|
        %w(container2).include?(container.name).should == true
        container.environment.should == env
        container.environment_id.should == env.id
      end
    end

  end

end
