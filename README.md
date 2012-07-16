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

TODO: Write usage instructions here


### Parallel

Parallel Processing Class

This class can be used to easily run iterative and linear processes in a parallel manner.

Example:

    parallel = ZTK::Parallel.new
    20.times do |x|
      parallel.process do
        x
      end
    end
    parallel.waitall
    parallel.results
    => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
