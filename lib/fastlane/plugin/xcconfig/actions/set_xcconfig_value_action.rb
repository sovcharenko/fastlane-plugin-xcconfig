require 'fastlane/action'
require_relative '../helper/xcconfig_helper'

module Fastlane
  module Actions
    class SetXcconfigValueAction < Action
      def self.run(params)
        path = File.expand_path(params[:path])

        tmp_file = path + '.updated'

        begin
          updated = false

          File.open(tmp_file, 'w') do |file|
            File.open(path).each do |line|
              name, = Helper::XcconfigHelper.parse_xcconfig_name_value_line(line)
              if name == params[:name]
                file.write(name + ' = ' + params[:value] + "\n")
                updated = true
              else
                file.write(line)
              end
            end
          end

          Fastlane::UI.user_error!("Couldn't find '#{params[:name]}' in #{params[:path]}.") unless updated

          FileUtils.cp(tmp_file, path)
        ensure
          File.delete(tmp_file)
        end
      end

      def self.description
        'Updates value of a setting in xcconfig file.'
      end

      def self.authors
        ["Sergii Ovcharenko"]
      end

      def self.return_value
        nil
      end

      def self.details
        'This action updates the value of a given setting in a given xcconfig file. Will throw an error if specified setting doesn\'t exist'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "XCCP_SET_VALUE_PARAM_NAME",
                                       description: "Name of key in xcconfig file",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "XCCP_SET_VALUE_PARAM_VALUE",
                                       description: "Value to set",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "XCCP_SET_VALUE_PARAM_PATH",
                                       description: "Path to plist file you want to update",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find xcconfig file at path '#{value}'") unless File.exist?(File.expand_path(value))
                                       end)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
