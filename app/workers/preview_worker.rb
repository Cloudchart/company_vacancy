class PreviewWorker < ApplicationWorker
  include Rails.application.routes.url_helpers

  def perform(class_name, id)
    record = class_name.constantize.find(id)
    preview = Tempfile.new(['preview', '.png'])
    begin
      system("#{ENV['PHANTOMJS_PATH']} --ssl-protocol=any #{File.join([Rails.root, 'bin', 'generate_preview.js'])} #{preview_url_for(record)} #{preview.path}")
      record.skip_generate_preview!
      record.update!(preview: preview)
    rescue
      preview.close
      preview.unlink
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
