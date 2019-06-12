module Fastlane
  module Actions

    class NrPodSpecLintAction < Action
      def self.run(params)
        commands = ["pod", "spec", "lint"]
        if params[:path]
          commands << params[:path]
        end

        if params[:quick]
          commands << "--quick"
        end

        if params[:allow_warnings]
          commands << "--allow-warnings"
        end

        if params[:no_subspecs]
          commands << "--no-subspecs"
        end

        if params[:subspec]
          commands << "--subspec=#{params[:subspec]}"
        end

        result = Actions.sh("#{commands.join(" ")}")
        UI.success("Successfully linted podspec")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        [
                    FastlaneCore::ConfigItem.new(key: :path,
                                                 description: "The Podspec you want to lint",
                                                 optional: true,
                                                 verify_block: proc do |value|
                                                   raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                                   raise "File must be a `.podspec`".red unless value.end_with?(".podspec")
                                                 end),
                    FastlaneCore::ConfigItem.new(key: :quick,
                                                 description: "Lint skips checks that would require to download and build the spec",
                                                 optional: true,
                                                 is_string:false),
                    FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                                 description: "Lint validates even if warnings are present",
                                                 optional: true,
                                                 is_string:false),
                    FastlaneCore::ConfigItem.new(key: :no_subspecs,
                                                 description: "Lint skips validation of subspecs",
                                                 optional: true,
                                                 is_string:false),
                    FastlaneCore::ConfigItem.new(key: :subspec,
                                                 description: "Lint validates only the given subspec",
                                                 optional: true,
                                                 is_string: true),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['NR_POD_SPEC_LINT_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
