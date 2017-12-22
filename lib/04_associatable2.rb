require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method(name) do
      # This one_liner hits database twice, but is much easier to read IMO
      # self.send(through_name).send(source_name)
      # input = :home, :human, :house. name looks unimportant

      through_options = self.class.assoc_options[through_name]
      through_table = through_options.table_name
      through_primary_key = through_options.primary_key

      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key

      result = DBConnection.execute(<<-SQL)
        SELECT
          DISTINCT #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{source_table}.#{through_primary_key} = #{self.id}
      SQL

      source_options.model_class.new(result.first)
    end
  end
end
