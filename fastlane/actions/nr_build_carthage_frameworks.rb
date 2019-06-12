module Fastlane
  module Actions
    module SharedValues
      CARTHAGE_FRAMEWORK = :CARTHAGE_FRAMEWORK
    end

    class NrBuildCarthageFrameworksAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Carthage archive: #{params[:framework_name]}"

        Actions.sh("carthage build --no-skip-current")
        Actions.sh("carthage archive #{params[:framework_name]}")

        path = "#{params[:framework_name]}.framework.zip"

        Actions.lane_context[SharedValues::CARTHAGE_FRAMEWORK] = path

        UI.success("Carthage generated #{params[:framework_name]}.framework")

        return path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Create a Carthage Framework for your project"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :framework_name,
                                       env_name: "CARTHAGE_FRAMEWORK_NAME", # The name of the environment variable
                                       description: "The name of the framework for Carthage to generate", # a short description of this parameter
                                       is_string:true)
        ]
      end

      def self.output
        [
          ['CARTHAGE_FRAMEWORK', 'The path to the generate Carthage framework']
        ]
      end

      def self.return_value
        "The path to the zipped framework"
      end

      def self.authors
        ["Nicolae Rogojan"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
