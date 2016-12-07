class Attachment < ApplicationRecord
  include ImageUploader[:file]
end
