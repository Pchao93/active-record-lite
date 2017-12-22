require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns if @columns
    result = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{table_name};
    SQL
    @columns = result.map(&:to_sym)

  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
      setter_name = (column.to_s + '=').to_sym
      define_method(setter_name) do |val|
        self.attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.underscore + 's'
  end

  def self.all
    # ...

    sql_stuff = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name};
    SQL
    self.parse_all(sql_stuff)
  end

  def self.parse_all(results)
    # ...

    results.map do |hash|
      self.new(hash)
    end



  end

  def self.find(id)
    # ...
    object_hash = DBConnection.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?;
    SQL
    return nil if object_hash.nil?
    self.new(object_hash)

  end

  def initialize(params = {})
    # ...
    params.each do |key, val|
      key = key.to_sym
      if self.class.columns.include?(key)
        self.send((key.to_s + '=').to_sym, val)
      else
        raise "unknown attribute '#{key}'"
      end
    end

  end

  def attributes
    # ...
    return @attributes if @attributes
    @attributes = {}


  end

  def attribute_values
    # ...
    values = []
    attributes.each_value do |val|
      values << val
    end
    values
  end

  def insert
    # ...
    column_names = self.class.columns.map(&:to_s).join(', ')[4..-1]
    question_marks = []
    attribute_values.length.times do
      question_marks << '?'
    end
    question_marks = question_marks.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{column_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    column_names = self.class.columns.map do |column|
      column = column.to_s
      "#{column} = ?"
    end.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{column_names}
      WHERE
        id = ?;
    SQL
  end

  def save
    # ...
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
