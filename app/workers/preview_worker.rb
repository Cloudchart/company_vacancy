class PreviewWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(class_name, id)
    record = class_name.constantize.find(id)
    Rails.logger.info should_generate_preview?(record)
    return unless should_generate_preview?(record)
    preview = Tempfile.new(['preview', '.png'])
    begin
      system("#{ENV['PHANTOMJS_PATH']} --ssl-protocol=any #{File.join([Rails.root, 'bin', 'generate_preview.js'])} #{preview_url_for(record)} #{preview.path}")
      record.skip_generate_preview!
      record.preview = preview
      record.preview.name = 'preview.png'
      record.save!
    rescue
      preview.close
      preview.unlink
    end
  end


  def should_generate_preview?(record)
    case record.class.name
    when 'User'
      record.full_name.present?
    when 'Pin'
      record.content.present? && record.parent_id.blank?
    else
      true
    end
  end


  def preview_url_for(record)
    case record.class.name
    when 'Company'
      company_preview_url(record)
    when 'Pin'
      insight_preview_url(record)
    when 'Pinboard'
      pinboard_preview_url(record)
    when 'User'
      user_preview_url(record)
    else
      root_url
    end
  end

end
