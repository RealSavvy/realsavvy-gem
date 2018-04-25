require 'real_savvy/meta'
require 'real_savvy/resource'

class RealSavvy::Document

  attr_reader :document

  def initialize(document, status: nil)
    @document = document
    @status = status
  end

  def data
    @data ||= self.class.process_resources(document['data'], self)
  end

  alias results data

  def result
    data
  end

  def included
    @included ||= self.class.process_resources(document['included'], self)
  end

  def meta
    @meta ||= RealSavvy::Meta.new(document['meta'] || {})
  end

  def errors
    @errors ||= document['errors'] || {}
  end

  def status
    @status
  end

  def objects_lookup
    @objects_lookup ||= [*data, *included].compact.each_with_object({}) { |resource, result| result[resource.hash] = resource }
  end

  def inspect
    document.inspect
  end

  def self.process_resources(resources, document=nil)
    if resources.is_a?(Array)
      resources.map { |object| RealSavvy::Resource.new(object, document)  }
    elsif resources
      RealSavvy::Resource.new(resources, document)
    end
  end
end
