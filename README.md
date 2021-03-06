[![Gem Version](https://badge.fury.io/rb/ztk.png)](http://badge.fury.io/rb/ztk)
[![Build Status](https://secure.travis-ci.org/zpatten/ztk.png)](http://travis-ci.org/zpatten/ztk)
[![Coverage Status](https://coveralls.io/repos/github/zpatten/ztk/badge.png?branch=master)](https://coveralls.io/github/zpatten/ztk?branch=master)
[![Dependency Status](https://gemnasium.com/zpatten/ztk.png)](https://gemnasium.com/zpatten/ztk)
[![Code Climate](https://codeclimate.com/github/zpatten/ztk.png)](https://codeclimate.com/github/zpatten/ztk)

# ZTK

Zachary's Tool Kit contains a collection of reusable classes meant to simplify development of complex systems in Ruby.  These classes provide functionality I often find myself needing from project to project.  Instead of reinventing the wheel each time, I've started building a collection of reusable classes.  Easy-bake DSLs, parallel processing, complex logging, templating and many other useful design patterns, for example are all contained in simple, reusable classes with a common interface and configuration style.

## INSTALLATION

Add this line to your application's Gemfile:

    gem 'ztk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ztk

Then run the pry console to play with it:

    $ bundle exec ztk

## USAGE

- **ZTK::ANSI**

  This mixin module gives you the ability to easily add ANSI colors to strings.  It also has a method for stripping all ANSI codes out of a string.  Read more at the [ZTK::ANSI](http://zpatten.github.io/ztk/ZTK/ANSI.html) documentation.

- **ZTK::Background**

  Easily run a processes in the background.  Read more at the [ZTK::Background](http://zpatten.github.io/ztk/ZTK/Background.html) documentation.

- **ZTK::Benchmark**

  Benchmark your code and optionally display messages and/or an "activity" indicator (i.e. spinning cursor).  Read more at the [ZTK::Benchmark](http://zpatten.github.io/ztk/ZTK/Benchmark.html) documentation.

- **ZTK::Command**

  Execute local commands controlling STDOUT, STDERR and STDIN as needed plus enhanced Logger support.  Read more at the [ZTK::Command](http://zpatten.github.io/ztk/ZTK/Command.html) documentation.

- **ZTK::Config**

  Use Ruby based configuration files with ease.  Inspired by Chef's mixlib-config.  Read more at the [ZTK::Config](http://zpatten.github.io/ztk/ZTK/Config.html) documentation.

- **ZTK::DSL**

  Create your own DSL in seconds by inheriting this DSL class.  Featuring ActiveRecord style associations where DSL objects can `belong_to` or `has_many` other DSL objects.  Read more at the [ZTK::DSL::Base](http://zpatten.github.io/ztk/ZTK/DSL/Base.html) documentation.

- **ZTK::Locator**

  Search for files or directories backwards up the present working directory tree.  Read more at the [ZTK::Locator](http://zpatten.github.io/ztk/ZTK/Locator.html) documentation.

- **ZTK::Logger**

  Based off the core Ruby logger, this is meant to be a drop in replacement.  Features added logging information, including PID, uSec time resolution, method and line numbers of logging statements (i.e. the caller).  One can seamlessly chain Ruby loggers using ZTK:Logger, for example to output logs to both STDOUT and a log file on disk at the same time; all while maintaining compatibility with the core Ruby logger.  Read more at the [ZTK::Logger](http://zpatten.github.io/ztk/ZTK/Logger.html) documentation.

- **ZTK::Parallel**

  Easily turn linear iterative tasks into parallel tasks and leverage multiple cores to speed up processing of your large sets of data.  Read more at the [ZTK::Parallel](http://zpatten.github.io/ztk/ZTK/Parallel.html) documentation.

- **ZTK::Profiler**

  Build timing profiles easily with this class.  Allows for arbitrary nesting of profiles and provides full reporting.  Read more at the [ZTK::Profiler](http://zpatten.github.io/ztk/ZTK/Profiler.html) documentation.

- **ZTK::Report**

  Console based reporting class which allows you to easily output either list or spreadsheet based reports from sets of data.  Read more at the [ZTK::Report](http://zpatten.github.io/ztk/ZTK/Report.html) documentation.

- **ZTK::RescueRetry**

  Certain cases warrant retries when exceptions occur.  With this class you can wrap code allowing retries in certain scenarios.  The class allows for full customization so you can fit it easily to your needs.  Read more at the [ZTK::RescueRetry](http://zpatten.github.io/ztk/ZTK/RescueRetry.html) documentation.

- **ZTK::Spinner**

  The spinner `ZTK::Benchmark` relies on.  With this class you can bend it to YOUR will!  Read more at [ZTK::Spinner](http://zpatten.github.io/ztk/ZTK/Spinner.html) documentation.

- **ZTK::SSH**

  An SSH class that nicely wraps up all of the SSH gems into a nice uniform interface, complete with transfer progress callbacks and enhanced Logger support.  It is meant to function as a drop in replacement, but I admit this has not been heavily tested like in the case of the ZTK::Logger class.  It provides the ability to switch between SCP and SFTP for file transfers seamlessly.  Full SSH proxy support as well, plus methods to spawn up interactive SSH consoles via `Kernel.exec`.  Read more at the [ZTK::SSH](http://zpatten.github.io/ztk/ZTK/SSH.html) documentation.

- **ZTK::TCPSocketCheck**

  This class provides a convient way to test if something is listening on a TCP port.  One can test a varity of scenarios, including sending data across the socket and waiting for a response.  Read more at the [ZTK::TCPSocketCheck](http://zpatten.github.io/ztk/ZTK/TCPSocketCheck.html) documentation.

- **ZTK::Template**

  Easily create Erubis based content with this class.  Read more at the [ZTK::Template](http://zpatten.github.io/ztk/ZTK/Template.html) documentation.

- **ZTK::UI**

  UI management; this class encapsulates STDOUT, STDERR, STDIN and a Ruby logger; as well as some other helpful flags.  This allows you to easily present a unified UI interface and allows for easy redirection of that interface (really helpful when using StringIO's with rspec to test program output for example).  Read more at the [ZTK::UI](http://zpatten.github.io/ztk/ZTK/UI.html) documentation.

## CONTRIBUTING

I await your pull request.

# RUBIES TESTED AGAINST

* Ruby 2.0.0
* Ruby 2.2.4
* Ruby 2.3.0

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

* Author: Zachary Patten <zpatten AT jovelabs DOT io>
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
