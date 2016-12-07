class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(attachment_params)
    if @attachment.save
      redirect_to :root, notice: 'file was successfully created.'
    else
      render :new
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:message, :file)
  end
end