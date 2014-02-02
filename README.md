[![Gem Version](https://badge.fury.io/rb/ztk.png)](http://badge.fury.io/rb/ztk)
[![Dependency Status](https://gemnasium.com/zpatten/ztk.png)](https://gemnasium.com/zpatten/ztk)
[![Build Status](https://secure.travis-ci.org/zpatten/ztk.png)](http://travis-ci.org/zpatten/ztk)
[![Coverage Status](https://coveralls.io/repos/zpatten/ztk/badge.png?branch=master)](https://coveralls.io/r/zpatten/ztk)
[![Code Climate](https://codeclimate.com/github/zpatten/ztk.png)](https://codeclimate.com/github/zpatten/ztk)

# ZTK

Zachary's Tool Kit is a general purpose utility gem, featuring a collection of classes meant to simplify development of complex systems in Ruby.

- **ZTK::Background**

  Easily turn most iterative tasks into a parallel processes and easily leverage multiple cores to speed up processing large sets of data.

- **ZTK::DSL**

  Create your own DSL in seconds by inheriting this DSL class.  Featuring ActiveRecord style associations where DSL objects can `belong_to` or `has_many` other DSL objects.

- **ZTK::Logger**

  Based off the core Ruby logger, this is meant to be a drop in replacement.  Features added logging information, including PID, uSec time resolution, method and line numbers of logging statements (i.e. the caller).  One can seamlessly chain Ruby loggers using ZTK:Logger, for example to output logs to both STDOUT and a log file on disk at the same time; all while maintaining compatibility with the core Ruby logger.

- **ZTK::SSH**

  An SSH class that nicely wraps up all of the SSH gems into a nice uniform interface, complete with transfer progress callbacks.  It is meant to function as a drop in replacement, but I admit this has not been heavily tested like in the case of the ZTK::Logger class.  It provides the ability to switch between SCP and SFTP for file transfers seamlessly.  Full SSH proxy support as well, plus methods to spawn up interactive SSH consoles via `Kernel.exec`.

# RUBIES TESTED AGAINST

* Ruby 1.8.7 (REE)
* Ruby 1.8.7 (MBARI)
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0

# RESOURCES

IRC:

* #jovelabs on irc.freenode.net

Documentation:

* http://zpatten.github.io/ztk/

Source:

* https://github.com/zpatten/ztk

Issues:

* https://github.com/zpatten/ztk/issues

# LICENSE

ZTK - Zachary's Tool Kit

* Author: Zachary Patten <zachary AT jovelabs DOT com> [![endorse](http://api.coderwall.com/zpatten/endorsecount.png)](http://coderwall.com/zpatten)
* Copyright: Copyright (c) Zachary Patten
* License: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
