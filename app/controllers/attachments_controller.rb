class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
    @repo_names = Attachment::REPOSITORIES.map do |repo_name|
      { name: repo_name, branch: Attachment.branch(repo_name), log: Attachment.log(repo_name) }
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
    flash[:danger] = "エラーが発生したため実行できませんでした: #{e.message}(#{e.class})"
    redirect_to :root
    Rails.application.config.shellscript_error_logger.info(e)
  end

  def create_zip
    zip_name = Attachment.zip_public_dir(rollback_params[:repo_name_zip])
    flash[:success] = "正常に実行しました。ファイル: #{request.origin + '/' + zip_name}.zip"
    redirect_to :root
  rescue => e
    flash[:danger] = "エラーが発生したため実行できませんでした: #{e.message}(#{e.class})"
    redirect_to :root
    Rails.application.config.shellscript_error_logger.info(e)
  end

  private

  def attachment_params
    # repo_nameとrepo_name_zipがあるの微妙そう
    params.require(:attachment).permit(:message, :file, :repo_name, :repo_name_zip)
  end

  def rollback_params
    params.permit!
  end
end
