module RealSavvy::Resource

end

require 'real_savvy/resource/base'
Dir[File.dirname(__FILE__) + '/resource/*.rb'].each {|file| require file }
