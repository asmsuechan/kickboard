class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
    @repo_names = Attachment::REPOSITORIES.map do |repo_name|
      { name: repo_name, log: Attachment.log(repo_name) }
    end
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

  def rollback
    Attachment.rollback(rollback_params[:repo_name])
    flash[:success] = '正常に実行しました。'
    redirect_to :root
  rescue => e
    binding.pry
    flash[:danger] = "エラーが発生したため実行できませんでした: #{e}"
    redirect_to :root
    Rails.application.config.shellscript_error_logger.info(e)
  end

  private

  def attachment_params
    params.require(:attachment).permit(:message, :file, :repo_name)
  end

  def rollback_params
    params.permit!
  end
end
