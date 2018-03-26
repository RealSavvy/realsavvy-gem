module RealSavvy
  module JWT
    class Token < AbstractToken

      def to_share_token
        share_token_payload_keys = ['aud','sub']
        share_token_payload = ::Hash[[share_token_payload_keys, claims.values_at(*share_token_payload_keys)].transpose]
        ShareToken.new(
          ::JWT.encode(
            share_token_payload, nil, 'none'
          )
        )
      end

      private

      def retrieve_claims
        @claims, @header = ::JWT.decode(
                              token,
                              ::RealSavvy::JWT::Config.public_key,
                              true,
                              algorithm: 'RS256',
                            )
      rescue ::JWT::DecodeError => e
        raise ::RealSavvy::JWT::BadCredentials.new(e.message)
      end

      def validate_token
        ::RealSavvy::JWT::Config.validate_token(token)
      end
    end
  end
end
