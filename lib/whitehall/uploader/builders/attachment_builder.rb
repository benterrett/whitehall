require 'whitehall/uploader/builders'

class Whitehall::Uploader::Builders::AttachmentBuilder
  def self.build(attributes, url, cache, logger, line_number)
    begin
      file = cache.fetch(url)
    rescue Whitehall::Uploader::AttachmentCache::RetrievalError => e
      logger.error "Row #{line_number}: Unable to fetch attachment '#{url}' - #{e.to_s}"
    end
    attachment_data = AttachmentData.new(file: file)
    attachment = Attachment.new(attributes.merge(attachment_data: attachment_data))
    attachment.build_attachment_source(url: url)
    attachment
  end
end
