require 'real_savvy/resource'

class RealSavvy::Document

  attr_reader :document

  TYPE_TO_RESOURCE = {
    'properties' => RealSavvy::Resource::Property,
    'listings' => RealSavvy::Resource::Property,
    'collections' => RealSavvy::Resource::Collection,
    'saved_searches' => RealSavvy::Resource::SavedSearch,
    'users' => RealSavvy::Resource::User,
  }.tap do |lookup|
    lookup.default = RealSavvy::Resource::Base
  end.freeze

  def initialize(document, status: nil)
    @document = document
    @status = status
  end

  def data
    @data ||= self.class.process_resources(document['data'], self)
  end

  alias results data

  def result
    data[0]
  end

  def included
    @included ||= self.class.process_resources(document['included'], self)
  end

  def meta
    @meta ||= document['meta'] || {}
  end

  def errors
    @errors ||= document['errors'] || {}
  end

  def status
    @status
  end

  def objects_lookup
    @objects_lookup ||= (data + included).each_with_object({}) { |resource, result| result[resource.hash] = resource }
  end

  def inspect
    document.inspect
  end

  def self.process_resources(resources, document=nil)
    ::RealSavvy.safe_wrap(resources).map { |object| TYPE_TO_RESOURCE[object['type']].new(object, document)  }
  end
end
