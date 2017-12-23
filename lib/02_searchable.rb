require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    self
    Relation.new(self, self.table_name, params)


  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end

class Relation

  def initialize(target_class, table, params)
    @table = table
    @target_class = target_class
    @params = params
    columns = []
    values = []
    params.each do |key, val|
      key = key.to_s
      columns << "#{key} = ?"
      values << val

    end

    @columns = columns
    @values = values
  end

  def execute
    return @result if @result
    reg_columns = @columns.join(' AND ')
    results = DBConnection.execute(<<-SQL, *@values)
      SELECT
        *
      FROM
        #{@table}
      WHERE
        #{reg_columns}
    SQL

    return [] if results.empty?
    @result = results.map { |result| @target_class.new(result) }
  end

  def where(params)
    params.each do |key, val|
      key = key.to_s
      columns << "#{key} = ?"
      values << val
    end
  end

  def method_missing(name, *args)
    self.execute.send(name, *args)
  end


end
