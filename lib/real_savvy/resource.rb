require 'set'
require 'real_savvy/attributes'
require 'real_savvy/links'

class RealSavvy::Resource
  attr_reader :json, :document

  def initialize(json, document)
    @json = json
    @document = document
  end

  def hash
    {id: id, type: type}.to_json.hash
  end

  def id
    json['id']
  end

  def type
    json['type']
  end

  def attributes
    @attributes ||= RealSavvy::Attributes.new(json['attributes'] || {})
  end

  def links
    @links ||= RealSavvy::Links.new(json['links'] || {})
  end

  def meta
    @meta ||= RealSavvy::Meta.new(json['meta'] || {})
  end

  def relationships
    self
  end

  def inspect
    json.inspect
  end

  private

  def objects_lookup
    document&.objects_lookup || {}
  end

  def loaded_relationships
    @loaded_relationships ||= {}
  end

  def has_relationship(relationship)
    possible_relation_ship = json['relationships']&.[](relationship.to_s)
    possible_relation_ship && possible_relation_ship.length > 0
  end

  def build_relationship(relationship)
    relationship_raw = json['relationships']&.[](relationship.to_s)&.[]('data')
    relationship_processed = ::RealSavvy::Document.process_resources(relationship_raw)
  end

  def load_relationship_with_lookup(relationship)
    loaded_relationships[relationship] ||= begin
                                             relationship_object = build_relationship(relationship)
                                             if relationship_object.is_a?(Array)
                                               relationship_object.map { |resource| objects_lookup[resource.hash] || resource }
                                             else
                                               objects_lookup[relationship_object.hash] || relationship_object
                                             end
                                           end
  end

  def method_missing(m, *args, &block)
    if has_relationship(m)
      load_relationship_with_lookup(m)
    else
      super
    end
  end
end
