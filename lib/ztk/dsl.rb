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

require "active_support/inflector"

module ZTK

  # Generic Domain-specific Language Interface
  #
  # This module allows you to easily add attributes and relationships to classes
  # create a custom DSL in no time.
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
  # You specify the schema in the classes itself; there is no data storage at
  # this time, but I do plan to add support for loading/saving *datasets* to
  # disk.
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  module DSL

    # @author Zachary Patten <zachary@jovelabs.net>
    class DSLError < Error; end

    autoload :Base, "ztk/dsl/base"
    autoload :Core, "ztk/dsl/core"

  end
end
