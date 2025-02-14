# lib/tasks/dev/data/license_keys_tasks.rake
#
# This file contains two tasks:
#   rake dev:data:license_keys:csv:update[file_path]
#   rake dev:data:license_keys:csv:dump[headers]
#
# update
# ------
#
# Requires a valid CSV file having valid column names in its header row.  The
# "key" column is required.  All other database columns for the license_keys 
# table are optional.  It does not make sense to only have a header with only 
# the "key" column specified.
#
# The specified import file must:
#   * exist
#   * have a file extension of ".csv"
#
# This task DOES NOT create new records in the table.  It only updates existing 
# records with the data provided in the CSV file.
#
# Any row in the CSV file that has an error will be skipped.  These errors are 
# noted in the recap provided by the task.  All valid rows will be processed.
#
#
# dump
# ----
#
# This task will dump (aka export) the specified columns from the license_keys 
# table to a CSV file named "license_keys.csv" in the Rails.root directory.
#
# If no headers are specified, the task defaults to all table columns.

require 'csv'

class LicenseKeysTasks 
  include Rake::DSL 
  
  HEADERS_MUST_INCLUDE  = %w[key].freeze
  UPDATED_AT            = Time.now.utc


  # NOTE: This done to support testing in RSpec
  #
  attr_accessor :args, :file_path, :csv, :headers, :error_messages,
                :updated_successfully

  def initialize
    @args                 = nil
    @file_path            = nil
    @csv                  = nil
    @headers              = []
    @error_messages       = []
    @updated_successfully = 0

    namespace :dev do
      namespace :data do 
        namespace :license_keys do
          namespace :csv do 

            desc "Update the license_keys table from a CSV file"
            task :update, [:file_path] => [:environment] do |_t, args|
              @args                 = args
              @file_path            = Pathname.new args[:file_path]


              exit(-1) unless valid_file_path?
              exit(-1) unless valid_csv_header?

              update_table
              recap
            end


            desc "Dump the license_keys table as a CSV fill_breakable"
            task :dump, [:headers] => [:environment] do |_t, args|
              @headers = if args[:headers]
                ([args[:headers]] + args.extras)&.map {|e| e&.downcase&.strip}
                         else
                LicenseKey.column_names
                         end
            
              @error_messages = []

              exit(-1) unless valid_csv_header?

              generate_csv_file
            end
          end
        end
      end
    end
  end

  #############################################
  # NOTE: kept public to support testing in RSpec until
  #       a good way of testing private methods is installed.
  #
  # private 

  def show_error(a_message)
    $stderr.puts "ERROR: #{a_message}"

    @error_messages << a_message
  end

  # The file path must exist and have the proper extension
  #
  # Uses:
  #   @file_path
  #
  # Side Effects:
  #   sets @csv object
  #   sets @headers object
  #
  # Returns Boolean
  #
  def valid_file_path?
    if (result = @file_path.exist?) 
      if (result = (".csv" == @file_path.extname))
        @csv      = CSV.open(@file_path)
        @headers  = @csv.readline.map {|e| e&.downcase&.strip}
      else
        show_error "File Extension Must be '.csv' Not '#{@file_path.extname}'"
      end
    else
      show_error "File does not exist: #{@file_path.basename}"
    end

    result    
  end

  # The headers for the CSV file must be valid column names defined in
  # the database table.  The headers must also include specific column
  # names that comprise the "ident" object used to uniquely identify
  # a specific row in the table.
  #
  # Input:
  #   @headers 
  #
  # Returns Boolean
  #
  def valid_csv_header?
    columns = LicenseKey.column_names

    bad_headers = @headers - columns

    result = bad_headers.empty?

    if result 
      result = required_headers?
    else
      show_error "Invalid Headers: #{bad_headers.join(', ')}"
    end

    result
  end

  # Verify that all required headers are present.
  #
  # Input
  #   @headers .. An Array of Strings
  #
  # Side Effect
  #   @headers .. An Array of Symbols
  #
  # Returns a boolean
  #
  def required_headers?
    result = (HEADERS_MUST_INCLUDE - @headers).empty?

    if result
      @headers.map! {|e| e.to_sym}
    else
      show_error("Headers must include: #{HEADERS_MUST_INCLUDE.join(', ')}")
    end

    result
  end

  def update_table
    csv_to_array_of_hash.each do |entry|
      update_row(entry)
    end
  end

  # Convert the Array of Arrays object created by the CSV library
  # into an Array of Hashes.  The Hash keys must be symbols.
  #
  # Error checking is done to ensure that the data being
  # process meets the required format:
  #   * each row must have the same number of values as the header row
  #
  # Input
  #   @csv
  #
  # Returns and Array of Hashes
  #
  def csv_to_array_of_hash
    array_of_hashes = []

    line_number = 1 # NOTE: skipping the header line
    expected_column_count = @headers.size

    @csv.readlines.each do |entry|
      line_number += 1

      if entry.size == expected_column_count
        a_hash = {}

        @headers.size.times do |x|
          a_hash[@headers[x]] = entry[x]&.strip
        end

        array_of_hashes << a_hash
      else
        show_error "Invalid Column Count (expected: #{expected_column_count}; got: #{entry.size}) on Line: #{line_number} => #{entry.join(',')}"
      end
    end

    array_of_hashes
  end

  # Update a specific row based upon the "ident" object that uniquely
  # identifies the row to be updated.  If there is no row that matches
  # the "ident" object, an error condition is recorded.  The process
  # does not stop.
  #
  # Each entry will have the same updated_at timestamp regardless of
  # wheter the CSV file had a column for updated_at.  It if did, that
  # value is ignored.
  #
  # Input
  #   entry ... A hash with keys of type Symbol
  #
  # Returns an indeterminate object.  That is to say there is
  # specific contract for a returned object.
  #
  def update_row(entry)
    ident = entry.select {|k,_v| HEADERS_MUST_INCLUDE.include?(k.to_s)}

    row = LicenseKey.find_by(ident)

    if row.present?
      if UPDATED_AT == row.updated_at 
        show_error "Duplicate ident value(s): #{format_hash(ident)}"
        return
      end

      entry[:updated_at] = UPDATED_AT

      row.update_columns(entry)
      @updated_successfully += 1
    else
      show_error "Invalid ident value(s): #{format_hash(ident)}"
    end
  end

  # Takes any Hash object and formats it as a string.
  #
  # Input
  #   a_hash ... is a Hash clever, right?
  #
  # Returns a String that has this pattern:
  #   "key1:value1, key2:value2, ...."
  #
  def format_hash(a_hash)
    a_string = []

    a_hash.each_pair do |k,v|
      a_string << "#{k}:#{v}"
    end

    a_string.join(', ')
  end

  # Provides record counts and a list of error messages
  # generated while running the task.  Output is to
  # $stdout.
  #
  def recap
    title = "Updates from #{@file_path.basename}"

    puts "\n#{title}"
    puts "="*title.length
    puts "\nUpdated At:         #{UPDATED_AT}"
    puts   "Successful Updates: #{@updated_successfully}"
    puts   "Errors Encountered: #{@error_messages.size}"

    unless @error_messages.empty?
      puts "\nThe following ERRORS were encountered ..."
      puts @error_messages.join("\n")
    end

    puts
  end

  # Use the SQL command COPY TO to generate a CSV file to
  # the default filename located at the Rails.root.
  #
  def generate_csv_file
    timestamp = Time.now.utc.strftime(TIMESTAMP_FORMAT)
    filename  = "#{Rails.env}_license_keys_#{timestamp}.csv"
    columns   = @headers.map{|c| c.to_sym}

    out_file_path = Rails.root + "db/data" + filename
    
    result    = LicenseKey.all.pluck(*columns)
    a_string  = @headers.join(',') + "\n"
    
    result.each do |row|
      a_string += row.join(',') + "\n"
    end

    out_file_path.write a_string
  end

  # Format the desired CSV headers using the pattern required
  # bu the SQL COPY TO and COPY FROM statements.
  #
  def format_headers
    "(#{@headers.join(',')})"
  end
end

# Instantiate the class to define the tasks
LicenseKeysTasks.new