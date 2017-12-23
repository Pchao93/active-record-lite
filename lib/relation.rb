require_relative 'validatable'

class Relation

  def execute(table, columns, values)
    object_hashes = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{columns}
    SQL
  end

  def initialize(query)

  end

  def append_query(query)

  end

end
