class PdfMerger
  def initialize(pdfs)
    @pdfs = pdfs
    @files = []
  end

  def merge
    output_file = Tempfile.new
    args = %W[-dPrinted=false -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=#{output_file.path.shellescape}] + pdf_files.map(&:path)
    system "gs", *args, out: :close

    output = File.read(output_file)
    output_file.close!
    files.each(&:close!)

    output
  end

  def self.merge(pdfs)
    new(pdfs).merge
  end

  private

  attr_accessor :files

  def pdf_files
    @pdf_files ||= begin
      @pdfs.each do |pdf|
        Tempfile.open do |f|
          f.binmode
          f.puts(pdf)
          files.push(f)
        end
      end
      files
    end
  end
end