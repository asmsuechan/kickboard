# I referenced [here](https://www.sitepoint.com/rails-file-uploading-you-can-believe-in-with-shrine/)
# TODO: ImageをFileにリネーム
class ImageUploader < Shrine
  include ImageProcessing::MiniMagick

  plugin :activerecord
  plugin :determine_mime_type
  plugin :logging, logger: Rails.logger
  plugin :remove_attachment
  plugin :store_dimensions
  plugin :validation_helpers
  plugin :versions, names: [:original, :thumb]

  Attacher.validate do
    # TODO: 最大ファイルサイズを決める
    # validate_max_size 2.megabytes, message: 'is too large (max is 2 MB)'
    # validate_mime_type_inclusion ['/jpg', 'image/jpeg', 'image/png', 'image/gif']
    validate_mime_type_inclusion ['application/zip']
  end

  def process(io, context)
    #case context[:phase]
    # when :store
    #   thumb = resize_to_limit!(io.download, 200, 200)
    #   { original: io, thumb: thumb }
    # end
  end
end
