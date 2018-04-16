module RealSavvy
  module JWT
    class AbstractToken
      # In order of access level
      SCOPE_VERBS = %w{public read write admin}.freeze

      attr_reader :scopes, :user, :site, :token, :header, :claims

      def initialize(token)
        @token = token
        standardized_token
        retrieve_claims
        retrieve_scopes
        retrieve_audience
        retrieve_site
        retrieve_subject
        retrieve_user
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
        scope_includes?(*scope_parts) || fail(::RealSavvy::JWT::Unauthorized)
      end

      def self.verbs_matches(verb)
        verb_index = SCOPE_VERBS.index(verb)
        verb_index ? SCOPE_VERBS[verb_index..-1] : []
      end

      def for_site?
        audience_is_site? && subject_is_site?
      end

      def for_site!
        for_site? || fail(::RealSavvy::JWT::Unauthorized)
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
        for_user? || fail(::RealSavvy::JWT::Unauthorized)
      end

      def valid?
        claims && claims.length > 0 && (for_site? || for_user?) && validate_token
      end

      def validate_token
        raise NotImplementedError, "subclass did not define #validate_token"
      end

      def imposter?
        @imposter ? true : false
      end

      def short_token
        @token.split('.')[1]
      end

      private

      attr_reader :audience, :subject

      def retrieve_claims
        raise NotImplementedError, "subclass did not define #retrieve_claims"
      end

      def retrieve_audience
        @audience = ::RealSavvy::JWT::Config.retrieve_audience(self) if claims && claims['aud']
      end

      def retrieve_subject
        @subject = ::RealSavvy::JWT::Config.retrieve_subject(self) if claims && claims['sub']
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

      def standardized_token
        # If token needs to be cleaned up do it here in subclasses
      end
    end
  end
end
