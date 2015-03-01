require 'json'
require 'smtpapi'

module SendGrid
  class Mail
    attr_accessor :to, :to_name, :from, :from_name, :subject, :text, :html, :cc, 
      :bcc, :reply_to, :date, :smtpapi, :attachments, :message_id

    def initialize(params = {})
      params.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
      @headers     ||= {}
      @attachments ||= []
      @smtpapi     ||= Smtpapi::Header.new
      yield self if block_given?
    end

    def add_to(to_email)
      @smtpapi.add_to to_email
    end

    def add_attachment(path, name = nil)
      file   = File.new(path)
      name ||= File.basename(file)
      @attachments << {file: file, name: name}
    end

    def add_header(key, value)
      @headers[key] = value
    end

    # see http://tools.ietf.org/html/rfc5322#section-3.6.4 for what constitutes as a valid Message-ID format
    def message_id=(message_id)
      @message_id = message_id
      add_header("Message-ID", message_id)
    end

    def to_h
      payload = {
        :from        => @from,
        :fromname    => @from_name,
        :subject     => @subject,
        :to          => @to,
        :toname      => @to_name,
        :date        => @date,
        :replyto     => @reply_to,
        :cc          => @cc,
        :bcc         => @bcc,
        :text        => @text,
        :html        => @html,
        :'x-smtpapi' => @smtpapi.to_json,
        :files       => ({} unless @attachments.empty?)
      }.reject {|k,v| v.nil?}

      payload[:headers] = @headers.to_json if @headers.any?

      # smtpapi fixer
      if @to.nil? and not @smtpapi.to.empty?
        payload[:to] = payload[:from]
      end

      unless @attachments.empty?
        @attachments.each do |file|
          payload[:files][file[:name]] = file[:file]
        end
      end

      payload
    end
  end
end
