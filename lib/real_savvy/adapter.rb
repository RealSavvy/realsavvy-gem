require 'real_savvy/document'

module RealSavvy::Adapter

end

require 'real_savvy/adapter/base'
Dir[File.dirname(__FILE__) + '/adapter/*.rb'].each {|file| require file }
