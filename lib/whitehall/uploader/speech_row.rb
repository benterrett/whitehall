module Whitehall::Uploader
  class SpeechRow
    attr_reader :row

    def initialize(row, line_number, attachment_cache, logger = Logger.new($stdout))
      @row = row
      @line_number = line_number
      @logger = logger
      @attachment_cache = attachment_cache
    end

    def legacy_url
      row['old_url']
    end

    def title
      row['title']
    end

    def body
      row['body']
    end

    def summary
      row['summary']
    end

    def speech_type
      Finders::SpeechTypeFinder.find(row['type'], @logger, @line_number)
    end

    def role_appointment
      Finders::RoleAppointmentsFinder.find(delivered_on, row['delivered_by'], @logger, @line_number).first
    end

    def related_policies
      Finders::PoliciesFinder.find(row['policy_1'], row['policy_2'], row['policy_3'], row["policy_4"], @logger, @line_number)
    end

    def location
      row['event_and_location']
    end

    def first_published_at
      delivered_on
    end

    def delivered_on
      Parsers::DateParser.parse(row['delivered_on'], @logger, @line_number)
    end

    def attributes
      [:title, :summary, :body, :speech_type,
       :role_appointment, :delivered_on, :location,
       :related_policies, :first_published_at].map.with_object({}) do |name, result|
        result[name] = __send__(name)
      end
    end

  end
end
