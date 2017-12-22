require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
    @foreign_key = options[:foreign_key] ? options[:foreign_key] : (name.to_s + '_id').to_sym
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # p self_class_name
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
    @foreign_key = options[:foreign_key] ? options[:foreign_key] : (self_class_name.underscore + '_id').to_sym
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase.singularize
    # ...

  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      target = options.model_class.where(id: foreign_key)
      target.first
    end
  end

  def has_many(name, options = {})
    # ...

    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      foreign_key = options.foreign_key
      options.model_class.where(foreign_key =>
        self.send(options.primary_key))
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
