#!/usr/bin/env ruby
class ByteUnits
  attr_reader :valid_units
  @@valid_units = ['b','kb','mb','gb','tb','pb','eb','zb','yb']
  def self.unit_scale(unit)
    return 1 if unit == 'b'
    return 8 if unit == 'B'
    idx = @@valid_units.find_index(unit.downcase).to_i
    scale = 1
    idx.times do scale *= 1024 end
    scale *= 8 if unit[1] == unit[1].upcase
    return scale
  end

  def self.add_conversions
    @@valid_units.each do |input_unit|
      @@valid_uits.each do |output_unit|
        define_method "#{input_unit}_to_#{output_unit}" do |value|
          input_scale = ByteUnits.unit_scale input_unit
          output_scale = ByteUnits.unit_scale output_unit
          (unit * input_scale) / output_scale
        end
      end
    end
  end

  def initialize
    ByteUnits.add_conversions
  end

  def self.valid_units
    @@valid_units
  end

  def self.method_missing(method, *args)
    match = /(convert_)?(.+?)_to_(.*)/.match method.to_s
    return ArgumentError, "No Method Match for #{method}" if  match.nil?
    return ArgumentError, "Invalid parameters" if args.length != 1
    return ArgumentError, "#{match[2]}: unknown unit type" if @@valid_units.find_index(match[2].downcase).nil?
    return ArgumentError, "#{match[3]}: unknown unit type" if @@valid_units.find_index(match[3].downcase).nil?
    input = args[0].to_i
    input_scale = ByteUnits.unit_scale match[2]
    output_scale = ByteUnits.unit_scale match[3]
    input_in_bits = input * input_scale
    input_in_bits / output_scale
  end
end

def show_help
  puts "usage: byte_conversion <num> <src_units>_to_<dst_units>"
  puts "valid units: #{ByteUnits.valid_units}"
  puts "NB: all units are powers of two. E.G. 1 kb_to_b = 1024"
end

def args_okay
  (from,_,to) = ARGV[1].split("_")
  not ([ARGV.include?("-h"),
        ARGV.include?("--help"),
        ARGV.length != 2,
        ARGV[0] != "#{ARGV[0].to_i}",
        (not ByteUnits.valid_units.include?(from)),
        (not ByteUnits.valid_units.include?(to)),
       ].any?
      )
end

def main
  return show_help unless args_okay
  puts (ByteUnits.send ARGV[1], ARGV[0])
rescue
  show_help
end

if $0 == __FILE__
  main
end
