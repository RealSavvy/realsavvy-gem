module RealSavvy
  module JWT
    class Token
      # In order of access level
      SCOPE_VERBS = %w{public read write admin}.freeze

      attr_reader :scopes, :user, :site, :token

      def initialize(token)
        @token = token
        retrieve_claims
        retrieve_scopes
        retrieve_audience
        retrieve_site
        retrieve_subject
        retrieve_user
      end

      def self.public_key
        if block_given?
          @public_key = Proc.new
        else
          result = @public_key.is_a?(Proc) ? @public_key.call : @public_key
          result.is_a?(OpenSSL::PKey::RSA) ? result : OpenSSL::PKey::RSA.new(result)
        end
      end

      def self.public_key= value
        @public_key = value
      end

      def self.retrieve_audience claims = nil
        if block_given?
          @retrieve_audience = Proc.new
        else
          @retrieve_audience.call(claims)
        end
      end

      def self.retrieve_audience= value
        @retrieve_audience = value
      end

      def self.retrieve_subject claims = nil
        if block_given?
          @retrieve_subject = Proc.new
        else
          @retrieve_subject.call(claims)
        end
      end

      def self.retrieve_subject= value
        @retrieve_subject = value
      end

      def self.validate_token token = nil
        if block_given?
          @validate_token = Proc.new
        else
          @validate_token.call(token)
        end
      end

      def self.validate_token= value
        @validate_token = value
      end

      def self.decode(token)
        new(token)
      end

      def scope_includes?(*scope_parts)
        !scope_parts.empty? && (
          scope_parts = scope_parts.dup.map(&:to_s)
          verbs_matches = self.class.verbs_matches(scope_parts.pop)

          (0..scope_parts.length).any? do |depth|
            verbs_matches.any? do |verb|
              (scope_parts[0...depth] + [verb]).inject(scopes) do |m, v|
                m&.[](v)
              end
            end
          end
        )
      end

      def scope_includes!(*scope_parts)
        scope_includes?(*scope_parts) || fail(JWTUnauthorized)
      end

      def self.verbs_matches(verb)
        verb_index = SCOPE_VERBS.index(verb)
        verb_index ? SCOPE_VERBS[verb_index..-1] : []
      end

      def for_site?
        audience_is_site? && subject_is_site?
      end

      def for_site!
        for_site? || fail(JWTUnauthorized)
      end

      def for_user?
        audience_is_site? && (subject_is_user? || subject_is_imposter?)
      end

      def audience_is_site?
        audience.respond_to?(:is_real_savvy_site?) &&
        audience.is_real_savvy_site?
      end

      def subject_is_user?
        subject.respond_to?(:is_real_savvy_user?) &&
        subject.is_real_savvy_user?
      end

      def subject_is_imposter?
        subject.respond_to?(:is_real_savvy_imposter?) &&
        subject.is_real_savvy_imposter?
      end

      def subject_is_site?
        subject.respond_to?(:is_real_savvy_site?) &&
        subject.is_real_savvy_site?
      end

      def for_user!
        for_user? || fail(JWTUnauthorized)
      end

      def valid?
        claims && claims.length > 0 && (for_site? || for_user?) && self.class.validate_token(token)
      end

      def imposter?
        @imposter ? true : false
      end

      private

      attr_reader :claims, :audience, :subject

      def retrieve_claims
        @claims = ::JWT.decode(
          token,
          self.class.public_key,
          true,
          algorithm: 'RS256',
        ).first
      rescue ::JWT::DecodeError => e
        raise RealSavvy::JWT::BadCredentials.new(e.message)
      end

      def retrieve_audience
        @audience = self.class.retrieve_audience(claims) if claims
      end

      def retrieve_subject
        @subject = self.class.retrieve_subject(claims) if claims
      end

      def retrieve_site
        @site = audience
      end

      def retrieve_user
        if subject_is_user?
          @user = subject
        elsif subject_is_imposter?
          @user = subject.user
          @imposter = true
        end
      end

      def raw_scopes
        claims&.fetch('scopes', nil).to_a
      end

      def retrieve_scopes
        @scopes = raw_scopes.each_with_object({}) do |scope, result|
          scope.split(':').inject(result) { |m, v| m[v] ||= {} }
        end
      end
    end
  end
end
