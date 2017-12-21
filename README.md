[![Gem version](https://img.shields.io/gem/v/ddtelemetry.svg)](http://rubygems.org/gems/ddtelemetry)
[![Gem downloads](https://img.shields.io/gem/dt/ddtelemetry.svg)](http://rubygems.org/gems/ddtelemetry)
[![Build status](https://img.shields.io/travis/ddfreyne/ddtelemetry.svg)](https://travis-ci.org/ddfreyne/ddtelemetry)
[![Code Climate](https://img.shields.io/codeclimate/github/ddfreyne/ddtelemetry.svg)](https://codeclimate.com/github/ddfreyne/ddtelemetry)
[![Code Coverage](https://img.shields.io/codecov/c/github/ddfreyne/ddtelemetry.svg)](https://codecov.io/gh/ddfreyne/ddtelemetry)

# DDTelemetry

_DDTelemetry_ is a Ruby library for recording and analysing measurements in short-running Ruby processes.

If you are looking for a full-featured timeseries monitoring system, look no further than [Prometheus](https://prometheus.io/).

## Example

Take the following (naïve) cache implementation as a starting point:

```ruby
class Cache
  def initialize
    @map = {}
  end

  def []=(key, value)
    @map[key] = value
  end

  def [](key)
    @map[key]
  end
end
```

To start instrumenting this code, require `ddtelemetry`, create a counter, and record some metrics:

```ruby
require 'ddtelemetry'

class Cache
  attr_reader :counter

  def initialize
    @map = {}
    @counter = DDTelemetry::Counter.new
  end

  def []=(key, value)
    @counter.increment(:set)

    @map[key] = value
  end

  def [](key)
    if @map.key?(key)
      @counter.increment(:get_hit)
    else
      @counter.increment(:get_miss)
    end

    @map[key]
  end
end
```

Let’s construct a cache and exercise it:

```ruby
cache = Cache.new

cache['greeting']
cache['greeting']
cache['greeting'] = 'Hi there!'
cache['greeting']
cache['greeting']
cache['greeting']
```

Finally, get the recorded telemetry values:

```ruby
cache.counter.get(:set)      # => 1
cache.counter.get(:get_hit)  # => 3
cache.counter.get(:get_miss) # => 2
```

Or even print all stats:

```ruby
puts cache.counter
```

```
         │ count
─────────┼──────
get_miss │     2
     set │     1
 get_hit │     3
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ddtelemetry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ddtelemetry

## Usage

_DDTelemetry_ provides two metric types:

* A **counter** is an integer metric that only ever increases. Examples: cache hits, number of files written, …

* A **summary** records observations, and provides functionality for describing the distribution of the observations through quantiles. Examples: outgoing request durations, size of written files, …

Each metric is recorded with a label, which is a free-form object that is useful to further refine the kind of data that is being recorded. For example:

```ruby
cache_hits_counter.increment(:file_cache)
request_durations_summary.observe(:weather_api, 1.07)
```

NOTE: Labels will likely change to become key-value pairs in a future version of DDTelemetry.

### Counters

To create a counter, instantiate `DDTelemetry::Counter`:

```ruby
counter = DDTelemetry::Counter.new
```

To increment a counter, call `#increment` with a label:

```ruby
counter.increment(:file_cache)
```

To get the value for a certain label, use `#get`:

```ruby
counter.get(:file_cache)
# => 1
```

### Summaries

To create a summary, instantiate `DDTelemetry::Summary`:

```ruby
summary = DDTelemetry::Summary.new
```

To observe a value, call `#observe` with the value to observe, along with a label:

```ruby
summary.observe(0.88, :weather_api)
summary.observe(1.07, :weather_api)
summary.observe(0.91, :weather_api)
```

To get the list of observations for a certain label, use `#get`, which will return a `DDTelemetry::Stats` instance:

```ruby
summary.get(:weather_api)
# => <DDTelemetry::Stats>
```

The following methods are available on `DDTelemetry::Stats`:

* `#count`: returns the number of values
* `#sum`: returns the sum of all values
* `#avg`: returns the average of all values
* `#min`: returns the minimum value
* `#max`: returns the maximum value
* `#quantile(fraction)`: returns the quantile at the given fraction (0.0 – 1.0)

### Printing metrics

To print a metric, use `#to_s`. For example:

```ruby
summary = DDTelemetry::Summary.new

summary.observe(2.1, :erb)
summary.observe(4.1, :erb)
summary.observe(5.3, :haml)

puts summary
```

Output:

```
     │ count    min    .50    .90    .95    max    tot
─────┼────────────────────────────────────────────────
 erb │     2   2.10   3.10   3.90   4.00   4.10   6.20
haml │     1   5.30   5.30   5.30   5.30   5.30   5.30
```

### Stopwatch

The `DDTelemetry::Stopwatch` class can be used to measure durations. Use `#start` and `#stop` to start and stop the stopwatch, respectively, and `#duration` to read the value of the stopwatch:

```ruby
stopwatch = DDTelemetry::Stopwatch.new

stopwatch.start
sleep 1
stopwatch.stop
puts "That took #{stopwatch.duration}s."
# Output: That took 1.006831s.
```

A stopwatch, once created, will never reset its duration. Running the stopwatch again will add to the existing duration:

```ruby
stopwatch.start
sleep 1
stopwatch.stop
puts "That took #{stopwatch.duration}s."
# Output: That took 2.012879s.
```

You can query whether or not a stopwatch is running using `#running?`; `#stopped?` is the opposite of `#running?`.

## Development

Install dependencies:

    $ bundle

Run tests:

    $ bundle exec rake

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ddfreyne/ddtelemetry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DDTelemetry project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ddfreyne/ddtelemetry/blob/master/CODE_OF_CONDUCT.md).
