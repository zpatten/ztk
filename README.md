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

Example Code:

    $logger = ZTK::Logger.new(STDOUT)

    a_callback = Proc.new do |pid|
      puts "Hello from After Callback - PID #{pid}"
    end

    b_callback = Proc.new do |pid|
      puts "Hello from Before Callback - PID #{pid}"
    end

    parallel = ZTK::Parallel.new
    parallel.config.before_fork = b_callback
    parallel.config.after_fork = a_callback
    3.times do |x|
      parallel.process do
        x
      end
    end
    Hello from Before Callback - PID 30031
    Hello from After Callback - PID 30031
    Hello from Before Callback - PID 30031
    Hello from After Callback - PID 30050
    Hello from After Callback - PID 30031
    Hello from Before Callback - PID 30031
    Hello from After Callback - PID 30053
    Hello from After Callback - PID 30031
    Hello from After Callback - PID 30056
    parallel.waitall
    parallel.results

Example Code Pry Run:

    [1] pry(main)> $logger = ZTK::Logger.new(STDOUT)
    [2] pry(main)>
    [3] pry(main)> a_callback = Proc.new do |pid|
    [3] pry(main)*   puts "Hello from After Callback - PID #{pid}"
    [3] pry(main)* end
    => #<Proc:0x00000002cc3268@(pry):2>
    [4] pry(main)>
    [5] pry(main)> b_callback = Proc.new do |pid|
    [5] pry(main)*   puts "Hello from Before Callback - PID #{pid}"
    [5] pry(main)* end
    => #<Proc:0x00000002dbc228@(pry):5>
    [6] pry(main)>
    [7] pry(main)> parallel = ZTK::Parallel.new
    => #<ZTK::Parallel:0x00000002bf0688
     @config=
      #<OpenStruct stdout=#<IO:<STDOUT>>, stderr=#<IO:<STDERR>>, stdin=#<IO:<STDIN>>, logger=#<ZTK::Logger:0x000000027bc6e8 @progname=nil, @level=1, @default_formatter=#<Logger::Formatter:0x000000027bc558 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x000000027bc3a0 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mutex=#<Logger::LogDevice::LogDeviceMutex:0x000000027bc300 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x000000027bc198>>>>, max_forks=12, one_shot=false, before_fork=nil, after_fork=nil>,
     @forks=[],
     @results=[]>
    [8] pry(main)> parallel.config.before_fork = b_callback
    => #<Proc:0x00000002dbc228@(pry):5>
    [9] pry(main)> parallel.config.after_fork = a_callback
    => #<Proc:0x00000002cc3268@(pry):2>
    [10] pry(main)> 3.times do |x|
    [10] pry(main)*   parallel.process do
    [10] pry(main)*     x
    [10] pry(main)*   end
    [10] pry(main)* end
    Hello from Before Callback - PID 30031
    Hello from After Callback - PID 30031
    Hello from Before Callback - PID 30031
    Hello from After Callback - PID 30050
    Hello from After Callback - PID 30031
    Hello from Before Callback - PID 30031
    Hello from After Callback - PID 30053
    Hello from After Callback - PID 30031
    Hello from After Callback - PID 30056
    => 3
    [11] pry(main)> parallel.waitall
    => [[30050, #<Process::Status: pid 30050 exit 0>, 0],
     [30053, #<Process::Status: pid 30053 exit 0>, 1],
     [30056, #<Process::Status: pid 30056 exit 0>, 2]]
    [12] pry(main)> parallel.results
    => [0, 1, 2]

Config values can also be passed like:

    parallel = ZTK::Parallel.new(:before_fork => callback, :after_fork => callback)

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

