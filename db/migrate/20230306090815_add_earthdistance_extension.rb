# db/migrate/20230306090815_add_earthdistance_extension.rb

=begin
  The Earth Distance extension to PostgreSQL is officially
  supported and maintained.  It provides many different DB-level
  functions for geographic manipulations.

  Current the two functions being used in the polaris database
  be:

  * ll_to_earth ... which takes a decimal latitude, longitude degrees
  pair and returns a value in the point (aka earth) type; and,

  * earth_distance ... which takes two point types and returns
  the distance between them in meters which we then convert to
  miles by dividing it by 1609.34 meters / mile.

=end

class AddEarthdistanceExtension < ActiveRecord::Migration[6.1]
  def change
    execute(
      <<-QUERY
        CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE ;
      QUERY
    )
  end
end
