require "net/http"
require "uri"

module Central
  module Support
    module DiscordHelper
      def send_discord(integration, message)
        Central::Support::Discord.send(real_private_uri(integration.data['private_uri'] ),
                        integration.data['bot_username'],
                        message)
      end

      private def real_private_uri(private_uri)
        if private_uri.starts_with? "INTEGRATION_URI"
          return ENV[private_uri]
        end
        private_uri
      end
    end

    class Discord
      def self.send(private_uri, bot_username, message)
        Discord.new(private_uri, bot_username).send(message)
      end

      def initialize(private_uri, bot_username = "marvin")
        @private_uri = URI.parse(private_uri)
        @bot_username = bot_username
      end

      def send(text)
        if Rails.env.development?
          Rails.logger.debug("NOT SENDING TO OUTSIDE INTEGRATION!")
          Rails.logger.debug("URL: #{@private_uri}")
          Rails.logger.debug("Payload: #{payload(text)}")
        else
          Net::HTTP.post_form(@private_uri, payload(text))
        end
      end

      def payload(text)
        {
          username: @bot_username,
          content: text
        }
      end
    end
  end
end
