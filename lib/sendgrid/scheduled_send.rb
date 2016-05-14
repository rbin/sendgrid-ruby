module SendGrid
  class ScheduledSend
    def initialize(params)
      self.client = SendGrid::Client.new(params)
    end
    
    def client
      unless @client.is_a?(SendGrid::Client)
        fail SendGrid::Exception, "SendGrid::Client instance not found, please "\
                                  "initialize a client."
      end
      @client
    end
    
    def generate_batch_id
      client.post(endpoint: "/v3/mail/batch").body["batch_id"]
    end
    
    def validate_batch_id(batch_id)
      client.get(endpoint: "/v3/mail/batch/#{batch_id}").body["batch_id"]
    end
    
    def scheduled_send(batch_id)
      client.get(endpoint: "/v3/user/scheduled_sends/#{batch_id}").body[0]
    end
    
    def scheduled_sends
      client.get(endpoint: "/v3/user/scheduled_sends").body
    end
    
    def cancel_scheduled_send(batch_id)
      if scheduled_send(batch_id).nil?
        client.post(endpoint: "/v3/user/scheduled_sends", 
                    payload: {
                      batch_id: batch_id,
                      status: "cancel"
                    }).body
      else
        update_scheduled_send(batch_id, "cancel")
      end
    end
    
    def pause_scheduled_send(batch_id)
      if scheduled_send(batch_id).nil?
        client.post(endpoint: "/v3/user/scheduled_sends",
                    payload: { 
                      batch_id: batch_id, 
                      status: "pause"
                    }).body
      else
        update_scheduled_send(batch_id, "pause")
      end
    end
    
    def update_scheduled_send(batch_id, status)
      client.patch(endpoint: "/v3/user/scheduled_sends/#{batch_id}",
                   payload: { status: status }).body
    end
    
    def resume_scheduled_send(batch_id)
      client.delete(endpoint: "/v3/user/scheduled_sends/#{batch_id}").body
    end
    
  private
    
    def client=(client)
      unless client.api_user && client.api_key
        fail SendGrid::Exception, "ScheduledSend api requires a username and password for authorization."
      end
      client.conn.basic_auth(client.api_user, client.api_key)
      @client = client
    end
  end
end