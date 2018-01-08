require 'set'
require 'real_savvy/attributes'

class RealSavvy::Resource::Base
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
    @attributes || RealSavvy::Attributes.new(json['attributes'] || {})
  end

  def relationships
    self
  end

  def inspect
    json.inspect
  end

  def self.relationships
    @relationships ||= {}
  end

  def self.has_one relationship
    relationships[relationship.to_s] ||= {}
    relationships[relationship.to_s].merge!(single: true)
  end

  def self.belongs_to relationship
    has_one relationship
  end

  # Do nothing default behavior
  def self.has_many relationship

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
    loaded_relationships[relationship] ||= build_relationship(relationship).map { |resource| objects_lookup[resource.hash] || resource }
    self.class.relationships[relationship.to_s]&.[](:single) ? loaded_relationships[relationship].first : loaded_relationships[relationship]
  end

  def method_missing(m, *args, &block)
    if has_relationship(m)
      load_relationship_with_lookup(m)
    else
      super
    end
  end
end
