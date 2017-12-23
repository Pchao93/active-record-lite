require_relative '04_associatable2'

module Validatable
  def self.validates(columns, options = {})
    #columns is an array of the columns to validate
    if options[:presence]
      columns.each do |col|
        if "@#{col}".nil?
          return false
        end
      end
    end

    if options[:uniqueness]
      columns.each do |col|
        if self.class.where(col: self.col)
          return false
        end
      end
    end

    true
  end
end

class SQLObject
  extend Validatable
end
