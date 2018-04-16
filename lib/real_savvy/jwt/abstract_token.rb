module RealSavvy
  module JWT
    class AbstractToken
      # In order of access level
      SCOPE_VERBS = %w{public read write admin}.freeze

      attr_reader :token

      def initialize(token)
        @token = token
        standardized_token
      end

      # New token, plus makes sure there isn't any errors with the token
      def self.decode(token)
        new(token).tap do |new_token|
          new_token.valid?
        end
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
        user
        @imposter ? true : false
      end

      def short_token
        @token.split('.')[1]
      end

      def claims
        retrieve_claims unless @claims
        @claims
      end

      def header
        retrieve_claims unless @header
        @header
      end

      def site
        audience
      end

      def user
        @user ||= begin
                    if subject_is_user?
                      subject
                    elsif subject_is_imposter?
                      @imposter = true
                      subject.user
                    end
                  end
      end

      def scopes
        @scopes ||= raw_scopes.each_with_object({}) do |scope, result|
          scope.split(':').inject(result) { |m, v| m[v] ||= {} }
        end
      end

      private

      def retrieve_claims
        raise NotImplementedError, "subclass did not define #retrieve_claims"
      end

      def audience
        @audience ||= ::RealSavvy::JWT::Config.retrieve_audience(self) if claims && claims['aud']
      end

      def subject
        @subject ||= ::RealSavvy::JWT::Config.retrieve_subject(self) if claims && claims['sub']
      end

      def raw_scopes
        claims&.fetch('scopes', nil).to_a
      end

      def standardized_token
        # If token needs to be cleaned up do it here in subclasses
      end
    end
  end
end
