require 'sinatra'
require './setup'
require './lib/mdcliapi2'
require 'zlib'

init_app

get '/' do
  "Hello, world"
end

get '/route_login' do
  r = Route.find_by_user_name(params[:user_name])
  if r && r.password == params[:password]
    current_service_hash = SecureRandom.uuid
    r.current_service_hash = current_service_hash
    r.save
    current_service_hash
  else
    nil
  end
end

get %r{/(\w+)(/.*)?} do
  user_id = params[:captures][0]
  path = params[:captures].size == 2 ? params[:captures][1] : ""
  r = Route.find_by_user_name(user_id)
  return "The apple device #{user_id} you requested is not registered" unless r
  service = r.current_service_hash
  client = MajorDomoClient.new('tcp://geneva3.godfat.org:5555')
  client.send('mmi.service', service)
  reply = client.recv
  puts "Lookup #{service} service: #{reply}"
  unless reply == ["200"]
      client.close
      return "The apple device #{user_id} you requested is not online"
  end
  request = path

  # if query for an image
  m = %r{^/images/(?<img_index>\d+)(?:\.[[:alpha:]]+)?$}.match(request)
  if m
    client.send(service, request)
    buf = client.recv() # ["200", "Content-Type", "image/jpeg", ..., "more"]
    return [buf[0].to_i,
            {"Content-Type" => "image/jpeg",
             "Content-Dispositio" => "inline; filename=#{m['img_index']}.jpg",
             "Last-Modified" => Time.now.ctime.to_s}.merge(Hash[*buf[1..-2]]),
            Enumerator.new do |y|
              more_parts = true
              while more_parts
                buf = client.recv()
                more_parts = false if buf.size == 1
puts "[DEBUG] we've recved, more_parts = #{more_parts}, buf[0].size = #{buf[0].size} #{Time.now}"
                y << Zlib.inflate(buf[0])
              end
              client.close
            end]
  end
end # get '/:user_id/*.*'
