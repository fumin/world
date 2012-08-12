require 'sinatra'

class SinatraStream < Enumerator
  attr_accessor :stream_callback
  def close
    stream_callback.call
  end
end

class Client
  attr_accessor :err_msg, :service, :path
  def initialize user_id, path
    @err_msg = ""
    @client = nil
    @service = ""
    @path = path
    @user_id = user_id
  end
  def is_service_online?
    r = Route.find_by_user_name(@user_id)
    unless r
      @err_msg = "The apple device #{@user_id} you requested is not registered"
      return false
    end
    @service = r.current_service_hash
    @client = MajorDomoClient.new('tcp://geneva3.godfat.org:5555')
    @client.send('mmi.service', @service)
    reply = @client.recv
    unless reply == ["200"]
      @client.close
      @err_msg = "The apple device #{@user_id} you requested is not online"
      return false
    end
    true
  end

  def process_image_query return_filename
    built_in_query({"Content-Type" => "image/jpeg", 
                    "Content-Disposition" => "inline; filename=#{return_filename}",
                    "Last-Modified" => Time.now.ctime.to_s})
  end

  def query path
    status, headers, body = built_in_query({}, path)
    complete_body = ""
    body.each{|b| complete_body.concat(b)}
    body.close
    [status, headers, complete_body]
  end

  def built_in_query headers={}, request_path=@path
    @client.send(@service, request_path)
    buf = @client.recv() # ["200", "Content-Type", "image/jpeg", ..., "more"]
    stream = SinatraStream.new do |y|
               more_parts = true
               while more_parts
                 buf = @client.recv()
                 more_parts = false if buf.size == 1
puts "[DEBUG] we've recved, more_parts = #{more_parts}, buf[0].size = #{buf[0].size} #{Time.now}"
                 inflated_buf = begin
                                 Zlib.inflate(buf[0])
                               rescue
                                 buf[0]
                               end
                 y << inflated_buf
               end
             end
    stream.callback = Proc.new do
puts "[DEBUG] @client.closed!"
                        @client.close
                      end

    [buf[0].to_i,
     headers.merge(Hash[*buf[1..-2]]),
     stream]
  end

  def all_image_links limit, offset
    limit = limit.to_i; offset = offset.to_i
    number_of_photos = query("/number_of_images")[2].to_i
    all_img_links = (0...number_of_photos).to_a.reverse.map do |i|
                      %!<a href="/#{@user_id}/images/#{i}"><img src="/#{@user_id}/thumbnails/#{i}"></a>!
                    end
    [number_of_photos, all_img_links[offset...(offset+limit)]]
  end
end # module General
