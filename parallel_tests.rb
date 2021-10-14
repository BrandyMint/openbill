#!/usr/bin/env ruby

require 'benchmark'

THREADS_COUNT = 1_00

SCRIPT = './tests/assert_value.sh'

def usage
  $stderr.puts("Runs specified script in multi-thread mode")
  $stderr.puts("Usage: #{File.basename($0)}: [-t #{THREADS_COUNT}] [-s #{SCRIPT} ] -a <SYSTEM_ACCOUNT_UUID> -u <USER_ACCOUNT_UUID>")
  exit(2)
end

usage if ARGV.empty?

threads_count = THREADS_COUNT
script = SCRIPT
system_account_id = nil
user_account_id = nil

loop { case ARGV[0]
    when '-t' then  ARGV.shift; threads_count = ARGV.shift
    when '-s' then  ARGV.shift; script = ARGV.shift
    when '-a' then  ARGV.shift; system_account_id = ARGV.shift
    when '-u' then  ARGV.shift; user_account_id = ARGV.shift
    when /^-/ then  usage("Unknown option: #{ARGV[0].inspect}")
    else break
end; }

if system_account_id.nil? || user_account_id.nil?
  $stderr.puts("No system or user account specified")
  usage
end

threads = []

puts Benchmark.measure {
  threads_count.times do |i|
    threads << Thread.new do
      system(script, system_account_id, user_account_id)
    end
  end
  threads.map(&:join)
}
