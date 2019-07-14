require "base64"
require "./crego/version"
require "./crego/adapter"

class Crego

  @raw_io : IO

  @adapter : Crego::Adapter.class

  # :nodoc:
  def initialize(io : IO, adapter : Crego::Adapter.class)
    @raw_io = io
    @adapter = adapter
  end

  # Create a new Crego instance from a path by
  # opening a file
  def self.open(path, adapter = nil)
    file = File.open(path)
    from_io(file, adapter)
  end

  # Create a new Crego instance from an IO directly
  def self.from_io(io, adapter = nil)
    adapter = adapter ? adapter_from_name(adapter) : adapter_from_io(io)
    new(io, adapter)
  end

  # Create a new crego instance from a base64 encoded
  # image
  def self.from_b64(data, adapter = nil)
    string = Base64.decode(data)
    io = IO::Memory.new(string)
    from_io(io, adapter)
  end

  # Create a new Crego instance from a slice
  # of bytes
  def self.from_slice(slice, adapter = nil)
    io = IO::Memory.new(slice)
    from_io(io, adapter)
  end

  # Encode a String, IO, or Slice into the image by
  # modifying its pixels by a very small amount
  def encode(input : String | IO | Slice)
    if input.is_a?(Slice)
      bytes = input
    else
      bytes = input.try &.to_slice || input.gets_to_end.to_slice
    end

    @adapter.encode(bytes)
  end

  def decode
    @adapter.decode
  end

  private def self.adapter_from_name(name)
    case name.to_s
    when "png"
      Crego::PNGAdapter
    when "jpg", "jpeg"
      Crego::JPEGAdapter
    else
      raise "No adapter exists for #{name}"
    end
  end

  private def self.adapter_from_io(io)
    image_type = determine_image_type(io)
    case image_type
    when :png
      Crego::PNGAdapter
    when :jpg
      Crego::JPEGAdapter
    when :unknown
      raise "Unknown image type. Please specify an adapter explicitly."
    else
      raise "No adapter for images of type #{image_type}"
    end
  end

  private def self.determine_image_type(io)
    case io.peek.try &.[0, 2].to_a
    when [0x42, 0x4d]
      :bmp
    when [0x47, 0x49]
      :gif
    when [0x89, 0x50]
      :png
    when [0xff, 0xd8]
      :jpg
    when [0x49, 0x49], [0x5d, 0x5d]
      case io.peek.try &.[8..10].to_a
      when [0x41, 0x50, 0x43], [0x43, 0x52, 0x2]
        :unknown # do not recognise CRW or CR2 as tiff
      else
        :tiff
      end
    when [0x38, 0x42]
      :psd
    when [0x0, 0x0]
      case io.gets(3).try &.bytes.to_a.last
      when 1 then :ico
      when 2 then :cur
      else
        :unknown
      end
    when [0x3c, 0x73]
      :svg
    when [0x52, 0x49]
      case io.gets(10)
      when /WEBP/
        :webp
      else
        :unknown
      end
    else
      :unknown
    end
  end
end
