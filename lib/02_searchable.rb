require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    columns = []
    values = []
    params.each do |key, val|
      key = key.to_s
      columns << "#{key} = ?"
      values << val
    end
    columns = columns.join(' AND ')
    object_hashes = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{columns}
    SQL
    return object_hashes if object_hashes.empty?
    object_hashes.map { |object_hash| self.new(object_hash) }
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
