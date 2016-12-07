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
  rescue => e
    # TODO: ここでエラーフロントに通知する
    # TODO: ここでエラーをlog/sh_error.logに書き出す
  end

  private

  def attachment_params
    params.require(:attachment).permit(:message, :file, :repo_name)
  end
end
