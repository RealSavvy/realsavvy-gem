module RealSavvy
  module JWT
    module Config
      def self.public_key
        if block_given?
          @public_key = Proc.new
        else
          raise NotImplementedError, "public_key not provided" unless @public_key
          result = @public_key.is_a?(Proc) ? @public_key.call : @public_key
          result.is_a?(OpenSSL::PKey::RSA) ? result : OpenSSL::PKey::RSA.new(result)
        end
      end

      def self.public_key= value
        @public_key = value
      end

      def self.retrieve_audience token = nil
        if block_given?
          @retrieve_audience = Proc.new
        else
          raise NotImplementedError, "retrieve_audience logic not implemeted" unless @retrieve_audience
          @retrieve_audience.call(token)
        end
      end

      def self.retrieve_audience= value
        @retrieve_audience = value
      end

      def self.retrieve_subject token = nil
        if block_given?
          @retrieve_subject = Proc.new
        else
          raise NotImplementedError, "retrieve_subject logic not implemeted" unless @retrieve_subject
          @retrieve_subject.call(token)
        end
      end

      def self.retrieve_subject= value
        @retrieve_subject = value
      end

      def self.validate_token token = nil
        if block_given?
          @validate_token = Proc.new
        else
          raise NotImplementedError, "validate_token logic not implemeted" unless @validate_token
          @validate_token.call(token)
        end
      end

      def self.validate_token= value
        @validate_token = value
      end
    end
  end
end
