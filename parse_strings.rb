require 'set'

DEVELOPER_LANGUAGE = "ja"
VALID_PARAMETERS_WITH_SWIFT_TYPES = {"%d" => "Int", "%@" => "String"}

def parse_strings(path:,output:)
  strings_all = {}

  # parse keys and values by language
  Dir::glob("#{path}/*.lproj").each do |lproj_path|
    language = /([a-zA-Z\_\-]*.lproj)/.match(lproj_path)[0].sub(".lproj", "")
    strings_of_language = {}

    File.open("#{lproj_path}/Localizable.strings", 'r:utf-8') do |file|
      file.each_line do |string|
        key, value = string.chomp.split(" = ")
        key = key[1..-2]
        value = value[1..-3]
        strings_of_language[key] = value
      end
    end

    strings_all[language] = strings_of_language
  end

  # check all keys are same among languages
  keys_developer = Set.new(strings_all[DEVELOPER_LANGUAGE].keys)
  strings_all.keys.each do |language|
    keys_for_language = Set.new(strings_all[language].keys)
    if keys_for_language != keys_developer
      difference = keys_developer - keys_for_language
      puts "Keys #{difference.to_a * ", "} is missing in language #{language}!"
      exit 1
    end
  end

  # generate swift struct
  swift_contents = "import Foundation\n\n/* This is auto generated file. Do not modify manually. */\n\nstruct LocalizedStrings {\n"
  keys_developer.each do |key|
    values = strings_all.map {|language, strings| strings[key]}
    value_developer = strings_all[DEVELOPER_LANGUAGE][key]

    # check parameters in value are same amond language
    regexp_for_parameter = /#{VALID_PARAMETERS_WITH_SWIFT_TYPES.keys * "|"}/
    parameter_types = values.map do |value| 
      value.scan(regexp_for_parameter)
           .map {|occurence| VALID_PARAMETERS_WITH_SWIFT_TYPES[occurence]}
    end

    if parameter_types.uniq.count > 1
      puts "Parameters differ for \"#{key}\""
      exit 1
    end

    types = parameter_types.uniq.flatten
    if types.count >= 1
      arguments = types.map.with_index {|type, index| "_ value#{index}: #{type}"} * ","
      params = types.map.with_index {|type, index| "value#{index}"} * " ,"
      swift_contents += "    /// #{value_developer}\n"
      swift_contents += "    static func #{key}(#{arguments}) -> String {\n"
      swift_contents += "        return String.localizedStringWithFormat(NSLocalizedString(\"#{key}\", comment: \"\"), #{params})\n"
      swift_contents += "    }\n"
    else
      swift_contents += "    /// #{value_developer}\n"
      swift_contents += "    static var #{key}: String {\n"
      swift_contents += "        return NSLocalizedString(\"#{key}\", comment: \"\")\n"
      swift_contents += "    }\n"
    end
  end

  swift_contents += "}\n"

  File.write(output, swift_contents)
end

if ARGV.count < 2
  puts "Usage: $ ruby parse_strings.rb [path to Localizable.string] [path to generated swift file]"
else
  parse_strings(path: ARGV[0], output: ARGV[1])
end
