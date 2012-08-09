#!/usr/bin/env ruby

require "term/ansicolor"

String.send :include, Term::ANSIColor


if ARGV.count != 1
  puts ""
end
