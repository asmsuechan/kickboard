class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
    @repo_names = Attachment::REPOSITORIES
  end

  def create
    @attachment = Attachment.new(attachment_params)
    if @attachment.save
      flash[:success] = '正常に実行しました。'
      redirect_to :root
    else
      render :new
    end
  rescue => e
    flash[:danger] = "エラーが発生したため実行できませんでした: #{e}"
    redirect_to :root
    Rails.application.config.shellscript_error_logger.info(e)
  end

  private

  def attachment_params
    params.require(:attachment).permit(:message, :file, :repo_name)
  end
end
