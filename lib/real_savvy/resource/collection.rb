class RealSavvy::Resource::Collection < RealSavvy::Resource::Base
  belongs_to :user
  belongs_to :site
end
