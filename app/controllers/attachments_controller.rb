class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
    @repo_names = Attachment::REPOSITORIES
  end

  def create
    @attachment = Attachment.new(attachment_params)
    if @attachment.save
      redirect_to :root, notice: 'file was successfully created.'
    else
      render :new
    end
  rescue => e
    redirect_to :root, notice: "エラーが発生したため実行できませんでした: #{e}"
    Rails.application.config.shellscript_error_logger.info(e)
  end

  private

  def attachment_params
    params.require(:attachment).permit(:message, :file, :repo_name)
  end
end
