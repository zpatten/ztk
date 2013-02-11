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

module ZTK::DSL

  # Generic Domain-specific Language Interface
  #
  # This module allows you to easily add attributes and relationships to classes
  # to create a custom DSL in no time.
  #
  # You can then access these classes in manners similar to what *ActiveRecord*
  # provides for relationships.  You can easily link classes together; load
  # stored objects from Ruby rb files (think Opscode Chef DSL).
  #
  # I intend the interface to act like ActiveRecord for the programmer and a
  # nice DSL for the end user.  It's not meant to be a database; more like
  # a soft dataset in memory; extremely fast but highly volitale.  As always
  # you can never have your cake and eat it too.
  #
  # You specify the "schema" in the classes itself; there is no data storage at
  # this time, but I do plan to add support for loading/saving *datasets* to
  # disk.  Keep in mind since you do not specify type constrants in Ruby, one
  # can assign any object to an attribute.
  #
  # At this time if you do not specify an ID; one is auto generated.
  #
  # If you wish to create objects in a nested fashion the outer most object must
  # be started using the class name initializer.  Once inside the block you can
  # start using the relationship names and do not need to call any further
  # class initializers.
  #
  # You can also instantiate classes separately and associate them after the
  # fact.  That is not shown in this example.
  #
  # *example code*:
  #
  #     class Network < ZTK::DSL::Base
  #       has_many :servers
  #
  #       attribute :name
  #       attribute :gw
  #       attribute :network
  #       attribute :netmask
  #     end
  #
  #     class Server < ZTK::DSL::Base
  #       belongs_to :network
  #
  #       attribute :name
  #     end
  #
  #     Network.new do
  #       id :leet_net
  #       name "leet-net"
  #       gw "7.3.3.1"
  #       network "7.3.3.0"
  #       netmask "255.255.255.0"
  #
  #       server do
  #         name "leet-server"
  #       end
  #
  #       server do
  #         id :my_server
  #         name "my-server"
  #       end
  #
  #       server do
  #         name "dev-server"
  #       end
  #     end
  #
  #     Network.count
  #     Network.all
  #     Network.find(:leet_net)
  #
  #     Server.count
  #     Server.all
  #     Server.find(:my_server)
  #
  # *pry output*:
  #
  #     [1] pry(main)> class Network < ZTK::DSL::Base
  #     [1] pry(main)*   has_many :servers
  #     [1] pry(main)*
  #     [1] pry(main)*   attribute :name
  #     [1] pry(main)*   attribute :gw
  #     [1] pry(main)*   attribute :network
  #     [1] pry(main)*   attribute :netmask
  #     [1] pry(main)* end
  #     => #<Proc:0x0000000121f498@/home/zpatten/Dropbox/code/chef-repo/vendor/checkouts/ztk/lib/ztk/dsl/core/attributes.rb:45 (lambda)>
  #     [2] pry(main)> class Server < ZTK::DSL::Base
  #     [2] pry(main)*   belongs_to :network
  #     [2] pry(main)*
  #     [2] pry(main)*   attribute :name
  #     [2] pry(main)* end
  #     => #<Proc:0x00000001983108@/home/zpatten/Dropbox/code/chef-repo/vendor/checkouts/ztk/lib/ztk/dsl/core/attributes.rb:45 (lambda)>
  #     [3] pry(main)> Network.new do
  #     [3] pry(main)*   id :leet_net
  #     [3] pry(main)*   name "leet-net"
  #     [3] pry(main)*   gw "7.3.3.1"
  #     [3] pry(main)*   network "7.3.3.0"
  #     [3] pry(main)*   netmask "255.255.255.0"
  #     [3] pry(main)*
  #     [3] pry(main)*   server do
  #     [3] pry(main)*     name "leet-server"
  #     [3] pry(main)*   end
  #     [3] pry(main)*
  #     [3] pry(main)*   server do
  #     [3] pry(main)*     id :my_server
  #     [3] pry(main)*     name "my-server"
  #     [3] pry(main)*   end
  #     [3] pry(main)*
  #     [3] pry(main)*   server do
  #     [3] pry(main)*     name "dev-server"
  #     [3] pry(main)*   end
  #     [3] pry(main)* end
  #     => #<Network id=:leet_net attributes={:id=>:leet_net, :name=>"leet-net", :gw=>"7.3.3.1", :network=>"7.3.3.0", :netmask=>"255.255.255.0"}, has_many_references=1>
  #     [4] pry(main)> Network.count
  #     => 1
  #     [5] pry(main)> Network.all
  #     => [#<Network id=:leet_net attributes={:id=>:leet_net, :name=>"leet-net", :gw=>"7.3.3.1", :network=>"7.3.3.0", :netmask=>"255.255.255.0"}, has_many_references=1>]
  #     [6] pry(main)> Network.find(:leet_net)
  #     => [#<Network id=:leet_net attributes={:id=>:leet_net, :name=>"leet-net", :gw=>"7.3.3.1", :network=>"7.3.3.0", :netmask=>"255.255.255.0"}, has_many_references=1>]
  #     [7] pry(main)> Server.count
  #     => 3
  #     [8] pry(main)> Server.all
  #     => [#<Server id=2 attributes={:id=>2, :name=>"leet-server", :network_id=>:leet_net}, belongs_to_references=1>,
  #      #<Server id=:my_server attributes={:id=>:my_server, :name=>"my-server", :network_id=>:leet_net}, belongs_to_references=1>,
  #      #<Server id=4 attributes={:id=>4, :name=>"dev-server", :network_id=>:leet_net}, belongs_to_references=1>]
  #     [9] pry(main)> Server.find(:my_server)
  #     => [#<Server id=:my_server attributes={:id=>:my_server, :name=>"my-server", :network_id=>:leet_net}, belongs_to_references=1>]
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Base
    include(ZTK::DSL::Core)

    # @api private
    def self.inherited(base)
      # puts("inherited(#{base})")
      base.send(:extend, ZTK::DSL::Base::ClassMethods)
      base.instance_eval do
        attribute :id
      end
    end

    # @api private
    def self.included(base)
      # puts("included(#{base})")
    end

    # @api private
    def self.extended(base)
      # puts("extended(#{base})")
    end

    def initialize(&block)
      self.id = self.class.id
      self.class.dataset << self
      block_given? and ((block.arity < 1) ? instance_eval(&block) : block.call(self))

      primary_key_count = self.class.dataset.count do |d|
        # puts("d.id == #{d.id.inspect} / self.id == #{self.id.inspect}")
        d.id == self.id
      end
      # puts("primary_key_count == #{primary_key_count}")
      raise StandardError, "Primary key '#{self.id}' already exists!" if (primary_key_count > 1)
    end

    def inspect
      details = Array.new
      details << "attributes=#{attributes.inspect}" if attributes.count > 0
      details << "has_many_references=#{@has_many_references.count}" if @has_many_references
      details << "belongs_to_references=#{@belongs_to_references.count}" if @belongs_to_references
      "#<#{self.class.to_s} id=#{self.id.inspect} #{details.join(', ')}>"
    end

    # @author Zachary Patten <zachary@jovelabs.net>
    module ClassMethods

      def inspect
        details = Array.new
        details << "count=#{self.all.count}" if self.all.count > 0
        "#<#{self.class.to_s}:#{self.id} #{details.join(', ')}>"
      end

    end

  end

end
