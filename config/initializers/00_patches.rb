# This allows copying image contents
# See https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1#diff-3fd88ddd945ad24c4bd6f76c64c8790a
# Should be fixed post Rails 5.2

# frozen_string_literal: true

module ActiveStorage
  class Downloader #:nodoc:
    def initialize(blob, tempdir: nil)
      @blob    = blob
      @tempdir = tempdir
    end

    def download_blob_to_tempfile
      open_tempfile do |file|
        download_blob_to file
        verify_integrity_of file
        yield file
      end
    end

    private
      attr_reader :blob, :tempdir

      def open_tempfile
        file = Tempfile.open([ "ActiveStorage-#{blob.id}-", blob.filename.extension_with_delimiter ], tempdir)

        begin
          yield file
        ensure
          file.close!
        end
      end

      def download_blob_to(file)
        file.binmode
        blob.download { |chunk| file.write(chunk) }
        file.flush
        file.rewind
      end

      def verify_integrity_of(file)
        unless Digest::MD5.file(file).base64digest == blob.checksum
          raise ActiveStorage::IntegrityError
        end
      end
  end
end
