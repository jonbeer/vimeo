module Vimeo
  module Advanced
    module SimpleUpload
      class UploadError < RuntimeError; end

      autoload :Task,         'vimeo/advanced/simple_upload/task'
      autoload :Chunk,        'vimeo/advanced/simple_upload/chunk'

      # Uploads data (IO streams or files) to Vimeo.
      def upload(uploadable)
        
        case uploadable
        when File, Tempfile
          puts "In SimpleUpload.upload (File) - calling upload_file"
          upload_file(uploadable)
        when String
          puts "In SimpleUpload.upload (String) - calling upload_file"
          upload_file(File.new(uploadable))
        else
          puts "In SimpleUpload.upload - calling upload_io"
          upload_io(uploadable, uploadable.size)
        end
      end

      protected

      # Uploads an IO to Vimeo.
      def upload_io(io, size, filename = 'io.data')     
        
        puts "In SimpleUpload.upload_io"
        puts io
           
        raise "#{io.inspect} must respond to #read" unless io.respond_to?(:read)
        task = Task.new(self, @oauth_consumer, io, size, filename)
        task.execute
        task.video_id
      end

      # Helper for uploading files to Vimeo.
      def upload_file(file)
        file_path = file.path

        size     = File.size(file_path)
        basename = File.basename(file_path)
        io       = File.open(file_path)
        io.binmode

        upload_io(io, size, basename).tap do
          io.close
        end
      end
    end
  end
end