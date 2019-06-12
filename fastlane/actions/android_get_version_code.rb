module Fastlane
  module Actions
    require "shellwords"
    require "tempfile"
    require "fileutils"

    module SharedValues
      ANDROID_VERSION_CODE = :ANDROID_VERSION_CODE
    end

    class AndroidGetVersionCodeAction < Action

      def self.get_gradle_file(gradle_file)
        return Helper.test? ? GRADLE_FILE_TEST : gradle_file
      end


      def self.get_gradle_file_path(gradle_file)
        gradle_file = self.get_gradle_file(gradle_file)
        return File.expand_path(gradle_file).shellescape
      end


      def self.read_key_from_gradle_file(gradle_file, key)
        value = false
        begin
          file = File.new(gradle_file, "r")
          while (line = file.gets)
            next unless line.include? key
            components = line.strip.split(' ')
            value = components[components.length - 1].tr("\"", "")
            break
          end
          file.close
        rescue => err
          UI.error("An exception occured while reading gradle file: #{err}")
          err
        end
        return value
      end


      def self.run(params)
        gradle_file_path = self.get_gradle_file_path(params[:gradle_file])
        version_code = self.read_key_from_gradle_file(gradle_file_path, "versionCode")

        if version_code == false
          UI.user_error!("Unable to find the versionCode in build.gradle file at #{gradle_file_path}.")
        end

        UI.success("👍  Current Android Version Code is: #{version_code}")

        # Store the Version Code in the shared hash
        Actions.lane_context[SharedValues::ANDROID_VERSION_CODE] = version_code
      end

      def self.description
        "Get the Version Code of your Android project"
      end

      def self.details
        "This action will return current Version Code of your Android project."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :gradle_file,
                                  env_name: "FL_ANDROID_GET_VERSION_CODE_GRADLE_FILE",
                               description: "(optional) Specify the path to your app build.gradle if it isn't in the default location",
                                  optional: true,
                                      type: String,
                             default_value: "app/build.gradle",
                              verify_block: proc do |value|
                                UI.user_error!("Could not find app build.gradle file") unless File.exist?(value) || Helper.test?
                              end)
        ]
      end

      def self.output
        [
          ['ANDROID_VERSION_CODE', 'The Version Code of your Android project']
        ]
      end

      def self.return_value
        "The Version Code of your Android project"
      end

      def self.authors
        ["Igor Lamoš"]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end

      def self.example_code
        [
          'version_code = android_get_version_code # build.gradle is in the default location',
          'version_code = android_get_version_code(gradle_file: "/path/to/build.gradle")'
        ]
      end

    end
  end
end
