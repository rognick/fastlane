module Fastlane
  module Actions
    module SharedValues
      TEAMS_CUSTOM_VALUE = :TEAMS_CUSTOM_VALUE
    end

    class TeamsAction < Action
      def self.run(options)
        require 'net/http'
        require 'uri'

        uri = URI.parse(options[:teams_url])

        if !(uri.kind_of?(URI::HTTP) or uri.kind_of?(URI::HTTPS))
          UI.important("Invalid URL (#{uri}), must start with https://")
          return
        end

        payload = generate_teams_payload(options)

        json_headers = { 'Content-Type' => 'application/json' }
        uri = URI.parse(options[:teams_url])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.post(uri.path, payload.to_json, json_headers)

        check_response_code(response)

      end

      def self.check_response_code(response)
        if response.code.to_i == 200 && response.body.to_i == 1
          true
        else
          UI.user_error!("An error occurred: #{response.body}")
        end
      end

      def self.generate_teams_payload(options)
        color = (options[:success] ? '0078D7' : 'd70019')
        text = (options[:success] ? options[:title] : "<span style=\"color:##{color}\">Error</span>")
        title = (options[:success] ? options[:title] : "Error")

        should_add_payload = ->(payload_name) { options[:default_payloads].nil? || options[:default_payloads].join(" ").include?(payload_name.to_s) }


        base_facts = options[:facts].map do |obj|
          {
            name: obj[:name].to_s,
            value: link_formatter(obj[:value].to_s),
          }
        end

        if options[:payload].is_a?(String)
          UI.important("payload is String #{options[:payload]}")
          options[:payload] = JSON.parse options[:payload].gsub('=>', ':')
        end

        base_facts += options[:payload].map do |k, v|
          {
            name: k.to_s,
            value: link_formatter(v.to_s),
          }
        end

        teams_payload = {
          "@type" => "MessageCard",
          "@context" => "http://schema.org/extensions",
          themeColor: color,
          text: text,
          sections: [{
            markdown: true,
            text: options[:message],
            facts: base_facts
          }]
        }

        # Add the lane to the Teams message
        # This might be nil, if teams is called as "one-off" action
        if ENV["SONAR_PROJECT_NAME"]
          teams_payload[:sections] << {
            facts: [{
              name: 'Project Name',
              value: ENV["SONAR_PROJECT_NAME"]
            }]
          }
        end

        # Add the lane to the Teams message
        # This might be nil, if teams is called as "one-off" action
        if should_add_payload[:lane] && Actions.lane_context[Actions::SharedValues::LANE_NAME]
          teams_payload[:sections] << {
            facts: [{
              name: 'Lane',
              value: Actions.lane_context[Actions::SharedValues::LANE_NAME]
            }]
          }
        end

        git_facts = []
        # git branch
        if Actions.git_branch && should_add_payload[:git_branch]
          git_facts << {
            name: 'Branch',
            value: Actions.git_branch
          }
        end

        # git_author
        if Actions.git_author_email && should_add_payload[:git_author]
          git_facts << {
            name: 'Author',
            value: "[#{Actions.git_author_email}](mailto:#{Actions.git_author_email})"
          }
        end

        # last_git_commit
        if Actions.last_git_commit_message && should_add_payload[:last_git_commit]
          git_facts << {
            name: 'Commit',
            value: Actions.last_git_commit_message
          }
        end

        if !git_facts.empty?
          teams_payload[:sections] << {
            text: 'Git Info',
            facts: git_facts
          }
        end

        if !(options[:success])
          teams_payload[:sections] << {
            facts:[{
              name: 'Result',
              value: 'Error'
            }]
          }
        end

        return teams_payload

      end

      def self.link_formatter(link)
        if link =~ /\A#{URI::regexp(['http', 'https'])}\z/
          return "[#{link}](#{link})"
        end
        return link
      end

      #####################################################
      # @!group Documentation
      #####################################################
      def self.description
        "Send a message to your Microsoft Teams channel via the webhook connector"
      end

      def self.authors
        ["mbogh"]
      end

      def self.details
        "Send a message to your Microsoft Teams channel"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :title,
                                         env_name: "FL_TEAMS_TITLE",
                                         default_value: "Fastlane",
                                         description: "The title that should be displayed on Teams"),
            FastlaneCore::ConfigItem.new(key: :message,
                                         env_name: "FL_TEAMS_MESSAGE",
                                         description: "The message that should be displayed on Teams. This supports the standard Teams markup language"),
            FastlaneCore::ConfigItem.new(key: :facts,
                                         optional: true,
                                         default_value: [],
                                         type: Array,
                                         env_name: "FL_TEAMS_FACTS",
                                         description: "Optional facts"),
            FastlaneCore::ConfigItem.new(key: :teams_url,
                                         env_name: "TEAMS_URL",
                                         sensitive: true,
                                         description: "Create an Incoming WebHook for your Teams channel",
                                         verify_block: proc do |value|
                                           # UI.user_error!("Invalid URL, must start with https://") unless value.start_with? "https://"
                                           UI.important("Invalid URL, must start with https://") unless value.start_with? "https://"
                                         end),
            FastlaneCore::ConfigItem.new(key: :success,
                                         env_name: "FL_TEAMS_SUCCESS",
                                         description: "Was this build successful? (true/false)",
                                         optional: true,
                                         default_value: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :default_payloads,
                                         env_name: "FL_TEAMS_DEFAULT_PAYLOADS",
                                         description: "Remove some of the default payloads. More information about the available payloads",
                                         optional: true,
                                         type: Array),
            FastlaneCore::ConfigItem.new(key: :payload,
                                         env_name: "FL_TEAMS_PAYLOAD",
                                         description: "Add additional information to this post. payload must be a hash containing any key with any value",
                                         default_value: [],
                                         is_string: false),

        ]
      end

      def self.example_code
        [
          'teams(
            title: "Fastlane says hello",
            message: "App successfully released!",
            payload: {
              "Name" => "Value",
            },
            facts:[
              {
                "name"=>"Platform",
                "value"=>"Android
              },
              {
                "name"=>"Lane",
                "value"=>"android internal"
              }
            ],
            teams_url: "https://outlook.office.com/webhook/...",
            success: true,
          )'
        ]
      end

      def self.category
        :notifications
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
