require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class XcconfigHelper
      # https://pewpewthespells.com/blog/xcconfig_guide.html
      NAME_VALUE_PATTERN = /^\s*([_a-zA-Z]+[_a-zA-Z0-9]*(?:\[[^\]]*(?:=[^\]]*)?\])*)\s*=\s*(.*)/x

      # Revert fastlane's auto conversion of strings into booleans
      # https://github.com/fastlane/fastlane/pull/11923
      def self.coerce_value(value)
        if [true, false].include?(value)
          value ? 'YES' : 'NO'
        else
          value.strip
        end
      end

      def self.parse_xcconfig_name_value_line(line)
        # Strip comment and match
        match = line.partition('//').first.match(NAME_VALUE_PATTERN)
        if match
          key = match[1]
          value = match[2]
          [key.strip, value.strip]
        else
          []
        end
      end
    end
  end
end
