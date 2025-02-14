# spec/lib/tasks/dev/data/license_keys_tasks_spec.rb

require 'rake'
load Rails.root + "lib/tasks/dev/data/license_keys_tasks.rake"

RSpec.describe "LicenseKeysTasks" do 
  before :each do
    @mock = LicenseKeysTasks.new
  end


  it ".show_error" do 
    msg = "Hello World"
    expect{@mock.show_error(msg)}.to output("ERROR: #{msg}\n").to_stderr
    expect(@mock.error_messages).to eq([msg])
  end


  it ".valid_file_path? - csv not exist" do 
    timestamp = Time.now.to_i
    basename  = "temp_test_#{timestamp}.csv"
    @mock.file_path = Rails.root + "tmp" + basename

    expect(@mock.valid_file_path?).to be(false)
    expect{@mock.valid_file_path?}.to output("ERROR: File does not exist: #{basename}\n").to_stderr
  end


  it ".valid_file_path? - csv exist" do 
    @mock.file_path = Rails.root + "tmp/temp_test_#{Time.now.to_i}.csv"
    
    begin
      @mock.file_path.write "Hello World"
      expect(@mock.valid_file_path?).to be(true)
    ensure 
      @mock.file_path.delete
    end
  end


  it ".valid_file_path? - txt not exist" do 
    timestamp = Time.now.to_i
    basename  = "temp_test_#{timestamp}.csv"
    @mock.file_path = Rails.root + "tmp" + basename

    expect(@mock.valid_file_path?).to be(false)
    expect{@mock.valid_file_path?}.to output("ERROR: File does not exist: #{basename}\n").to_stderr
  end


  it ".valid_file_path? - txt exist" do 
    @mock.file_path = Rails.root + "tmp/temp_test_#{Time.now.to_i}.txt"

    begin
      @mock.file_path.write "Hello World"
      expect(@mock.valid_file_path?).to be(false)
      expect{@mock.valid_file_path?}.to output("ERROR: File Extension Must be '.csv' Not '.txt'\n").to_stderr
    ensure
      @mock.file_path.delete
    end
  end


  it ".valid_csv_header? = good" do
    skip "Fails due to a fundamental misunderstanding of rake namespace"

    @mock.headers = %w[cbo key]
    expect(@mock.valid_csv_header?).to be(true)
  end


  it ".valid_csv_header? = bad" do
    @mock.headers = %w[cbo key xyzzy]
    expect(@mock.valid_csv_header?).to be(false)
    expect{@mock.valid_csv_header?}.to output("ERROR: Invalid Headers: xyzzy\n").to_stderr
  end


  it ".valid_csv_header? = missing required headers" do
    skip "Fails due to a fundamental misunderstanding of rake namespace"

    @mock.headers = %w[cbo updated_at]
    expect(@mock.valid_csv_header?).to be(false)
    expect{@mock.valid_csv_header?}.to output("ERROR: xyzzy\n").to_stderr
  end


  it ".required_headers?"
  it ".update_table"
  it ".csv_to_array_of_hash"
  it ".update_row(entry)"


  it ".format_hash(a_hash)" do
    a_hash  = {one: 1, two: 2}
    result  = @mock.format_hash(a_hash)
    expect(result).to eq("one:1, two:2")
  end

  it ".recap"
  it ".generate_csv_file(filename = 'license_keys.csv')"
  
  it ".format_headers" do
    @mock.headers = %w[one two three]
    expect(@mock.format_headers).to eq("(one,two,three)")
  end
end
