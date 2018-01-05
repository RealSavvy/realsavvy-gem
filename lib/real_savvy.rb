require 'real_savvy/client'

module RealSavvy
  # From the rails Array.wrap method
  def self.safe_wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end
