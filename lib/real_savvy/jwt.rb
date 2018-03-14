require 'jwt'

module RealSavvy::JWT

end

require 'real_savvy/jwt/token'
Dir[File.dirname(__FILE__) + '/jwt/*.rb'].each {|file| require file }
