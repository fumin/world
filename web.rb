require 'sinatra'
require './lib/mdcliapi2'
require 'zlib'

require './setup'
require './client'

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

  client = Client.new path
  return client.err_msg unless client.is_service_online?(user_id)

  case path
  when %r{^/photo_album/?$}
    number_of_photos = client.query("/number_of_images")[2].to_i
    all_img_links = (0...number_of_photos).to_a.reverse.map do |i|
                      %!<a href="/#{user_id}/images/#{i}"><img src="/#{user_id}/thumbnails/#{i}"></a>!
                    end
    @img_links = all_img_links[0...25] # TODO: use wookmark!!
    erb :photo_album
  when %r{^/number_of_images/?$}
    client.built_in_query
  when %r{^/images/(?<img_index>\d+)(?:\.[[:alpha:]]+)?$}
    client.process_image_query "#{$1}_img.jpg"
  when %r{^/thumbnails/(?<img_index>\d+)(?:\.[[:alpha:]]+)?$}
    client.process_image_query "#{$1}_thumbnail.jpg"
  else
    [404, {}, ""]
  end
end # get '/:user_id/*.*'
