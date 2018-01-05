class RealSavvy::Resource::SavedSearch < RealSavvy::Resource::Base
  belongs_to :user
  belongs_to :site
end
