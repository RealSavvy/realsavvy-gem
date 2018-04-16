module RealSavvy
  module JWT
    class ShareToken < AbstractToken

      def self.from_ids(audience_id:, subject_id:)
        self.new(
          ::JWT.encode(
            {aud: audience_id, sub: subject_id}, nil, 'none'
          )
        )
      end

      def to_share_token
        self
      end

      private

      def retrieve_claims
        @claims, @header = ::JWT.decode(
                              token,
                              nil,
                              false,
                            )
      rescue ::JWT::DecodeError => e
        raise ::RealSavvy::JWT::BadCredentials.new(e.message)
      end

      def validate_token
        true
      end

      def standardized_token
        token_parts = @token.split('.')
        header = Base64.urlsafe_encode64({typ:"JWT",alg:"none"}.to_json, padding: false)
        @token = [header, (token_parts.length == 1 ? token_parts[0] : token_parts[1]), nil].join('.')
      end
    end
  end
end
