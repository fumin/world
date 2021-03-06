require 'sinatra'
require './lib/mdcliapi2'
require 'zlib'

require './setup'
require './client'

init_app

get '/' do
  erb :index
end

get '/support' do
  erb :support
end

post '/signup' do
  route = params[:route]
  return 400 unless route['username'] && route['password'] &&
                    route['password'].size > 6 && route['password'].size < 20
  Route.create(route).username
end

get '/route_login' do
  r = Route.find_by_username(params[:username])
  if r && r.password == params[:password]
    current_service_hash = SecureRandom.uuid
    r.current_service_hash = current_service_hash
    r.save
    current_service_hash
  else
    "wrong username or password"
  end
end

get %r{/(\w+)(/.*)?} do
  @user_id = params[:captures][0]
  path = params[:captures].size == 2 ? params[:captures][1] : ""
  path ||= ""

  client = Client.new @user_id, path
  return client.err_msg unless client.is_service_online?

  @batch_size = 25
  case path
  when %r{^/?$}
    client.close
    redirect to("/#{@user_id}/photo_album")
  when %r{^/photo_album/?$}
    @number_of_photos, @img_links = client.all_image_links(@batch_size, 0)
    erb :photo_album
  when %r{^/wookmark/?$}
    limit = params[:limit] || @batch_size; offset = params[:offset] || 0
    JSON.generate client.all_image_links(limit, offset)[1]
  when %r{^/number_of_images/?$}
    client.built_in_query
  when %r{^/images/(?<img_index>\d+)(?:\.[[:alpha:]]+)?$}
    return "image #{$1} doesn't exist" if client.all_image_links(@batch_size, 0)[0] <= $1.to_i
    client.is_service_online? # reconnect again because built_in_query closes socket
    client.process_image_query "#{$1}_img.jpg"
  when %r{^/thumbnails/(?<img_index>\d+)(?:\.[[:alpha:]]+)?$}
    return "image #{$1} doesn't exist" if client.all_image_links(@batch_size, 0)[0] <= $1.to_i
    client.is_service_online?
    client.process_image_query "#{$1}_thumbnail.jpg"
  else
    [404, {}, ""]
  end
end # get '/:user_id/*.*'
