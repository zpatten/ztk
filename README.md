[![Build Status](https://secure.travis-ci.org/jovelabs/ztk.png)](http://travis-ci.org/jovelabs/ztk)

# ZTK

Zachary's Toolkit

## Installation

Add this line to your application's Gemfile:

    gem 'ztk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ztk

## Usage

### ZTK::Parallel

Parallel Processing Class

This class can be used to easily run iterative and linear processes in a parallel manner.

Example Ruby Code:

    $logger = ZTK::Logger.new(STDOUT)
    a_callback = Proc.new do |pid|
      puts "Hello from After Callback - PID #{pid}"
    end
    b_callback = Proc.new do |pid|
      puts "Hello from Before Callback - PID #{pid}"
    end
    parallel = ZTK::Parallel.new
    parallel.config do |config|
      config.before_fork = b_callback
      config.after_fork = a_callback
    end
    3.times do |x|
      parallel.process do
        x
      end
    end
    parallel.waitall
    parallel.results

Example Code Pry Run:

    [1] pry(main)> $logger = ZTK::Logger.new(STDOUT)
    => #<ZTK::Logger:0x0000000204d498
     @default_formatter=#<Logger::Formatter:0x0000000204d290 @datetime_format=nil>,
     @formatter=nil,
     @level=1,
     @logdev=
      #<Logger::LogDevice:0x0000000204cfe8
       @dev=#<IO:<STDOUT>>,
       @filename=nil,
       @mutex=
        #<Logger::LogDevice::LogDeviceMutex:0x0000000204cf20
         @mon_count=0,
         @mon_mutex=#<Mutex:0x0000000204ce58>,
         @mon_owner=nil>,
       @shift_age=nil,
       @shift_size=nil>,
     @progname=nil>
    [2] pry(main)> a_callback = Proc.new do |pid|
    [2] pry(main)*   puts "Hello from After Callback - PID #{pid}"
    [2] pry(main)* end
    => #<Proc:0x0000000253e1a0@(pry):2>
    [3] pry(main)> b_callback = Proc.new do |pid|
    [3] pry(main)*   puts "Hello from Before Callback - PID #{pid}"
    [3] pry(main)* end
    => #<Proc:0x0000000274bda8@(pry):5>
    [4] pry(main)> parallel = ZTK::Parallel.new
    => #<ZTK::Parallel:0x000000026310d0
     @config=
      #<OpenStruct stdout=#<IO:<STDOUT>>, stderr=#<IO:<STDERR>>, stdin=#<IO:<STDIN>>, logger=#<ZTK::Logger:0x0000000204d498 @progname=nil, @level=1, @default_formatter=#<Logger::Formatter:0x0000000204d290 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x0000000204cfe8 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mutex=#<Logger::LogDevice::LogDeviceMutex:0x0000000204cf20 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x0000000204ce58>>>>, max_forks=12, one_shot=false, before_fork=nil, after_fork=nil>,
     @forks=[],
     @results=[]>
    [5] pry(main)> parallel.config do |config|
    [5] pry(main)*   config.before_fork = b_callback
    [5] pry(main)*   config.after_fork = a_callback
    [5] pry(main)* end
    => #<Proc:0x0000000253e1a0@(pry):2>
    [6] pry(main)> 3.times do |x|
    [6] pry(main)*   parallel.process do
    [6] pry(main)*     x
    [6] pry(main)*   end
    [6] pry(main)* end
    Hello from Before Callback - PID 31579
    Hello from After Callback - PID 31579
    Hello from Before Callback - PID 31579
    Hello from After Callback - PID 31614
    Hello from After Callback - PID 31579
    Hello from Before Callback - PID 31579
    Hello from After Callback - PID 31617
    Hello from After Callback - PID 31579
    Hello from After Callback - PID 31620
    => 3
    [7] pry(main)> parallel.waitall
    => [[31614, #<Process::Status: pid 31614 exit 0>, 0],
     [31617, #<Process::Status: pid 31617 exit 0>, 1],
     [31620, #<Process::Status: pid 31620 exit 0>, 2]]
    [8] pry(main)> parallel.results
    => [0, 1, 2]

Config values can also be passed like:

    parallel = ZTK::Parallel.new(:before_fork => b_callback, :after_fork => a_callback)

Or:

    parallel = ZTK::Parallel.new
    parallel.config.before_fork = b_callback
    parallel.config.after_fork = a_callback

### ZTK::Logger

Logging Class

This is a logging class based off the ruby core Logger class; but with very verbose logging information, adding PID, micro second timing to log messages.  It favors passing messages via blocks in order to speed up execution when log messages do not need to be yielded.  New takes the same options as the ruby core logger class.

Example:

    $logger = ZTK::Logger.new("/dev/null")

    $logger.debug { "This is a debug message!" }
    $logger.info { "This is a info message!" }
    $logger.warn { "This is a warn message!" }
    $logger.error { "This is a error message!" }
    $logger.fatal { "This is a fatal message!" }

