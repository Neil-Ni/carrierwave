require 'spec_helper'

describe CarrierWave::Uploader do

  it "should keep callbacks on different classes isolated" do
    default_before_callbacks = [
      :check_extension_whitelist!,
      :check_extension_blacklist!,
      :check_content_type_whitelist!,
      :check_content_type_blacklist!,
      :check_size!,
      :process!
    ]
    @uploader_class_1 = Class.new(CarrierWave::Uploader::Base)

    # First Uploader only has default before-callbacks
    expect(@uploader_class_1._before_callbacks[:cache]).to eq(default_before_callbacks)

    @uploader_class_2 = Class.new(CarrierWave::Uploader::Base)
    @uploader_class_2.before :cache, :before_cache_callback

    # Second Uploader defined with another callback
    expect(@uploader_class_2._before_callbacks[:cache]).to eq(default_before_callbacks + [:before_cache_callback])

    # Make sure the first Uploader doesn't inherit the same callback
    expect(@uploader_class_1._before_callbacks[:cache]).to eq(default_before_callbacks)
  end

  context 'when before cache callback exists' do
    before do
      @uploader_class = Class.new(CarrierWave::Uploader::Base)
      @uploader = @uploader_class.new
      @file = File.open(file_path('test.jpg'))
      @sanitized_file = CarrierWave::SanitizedFile.new(@file)
      allow(@sanitized_file).to receive(:original_filename).at_least(:once).and_return("test-s,%&m#st?.jpg")
      allow(@uploader).to receive(:before_cache_callback)
      @uploader_class.before :cache, :before_cache_callback
      @uploader.cache!(@sanitized_file)
    end

    it "returns original file with unsanitize filename" do
      expect(@uploader).to have_received(:before_cache_callback) do |arg|
        expect(arg.original_filename).to eq "test-s,%&m#st?.jpg"
      end
    end
  end
end
