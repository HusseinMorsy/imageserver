require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'do_sqlite3'

use Rack::Auth::Basic do |username, password|
  [username, password] == ['kieferserver', 'bilder']
end


configure :development do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/imageserver.sqlite3")
end

configure :production do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/imageserver.sqlite3")
end


class Image
  include DataMapper::Resource

  property :name, String, :key => true
  property :content_type, String
  property :size, String

  def filename
    name + ".jpg"
  end

  def handle_upload( file )
    self.content_type = file[:type]
    self.size = File.size(file[:tempfile])
    path = File.join(Dir.pwd, "/public", self.filename)
    File.open(path, "wb") do |f|
      f.write(file[:tempfile].read)
    end
  end

  def delete
    File.delete File.join(Dir.pwd, "/public",self.filename)
    self.destroy
  end
end

configure :development do
  # Create or upgrade all tables at once, like magic
  DataMapper.auto_upgrade!
end

# set utf-8 for outgoing
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  @images = Image.all(:order => [:name.asc])
  haml :list
end

get '/new' do
   haml :new
end

get '/hello' do
  "hello"
end

post '/new' do
  name = params[:name]

  image = Image.new(:name => name)
  image.handle_upload(params[:image])
  if image.save
    redirect "/"
  else
    redirect "/new"
  end
end

get '/destroy' do
  filename = params[:filename]
  image = Image.first(:name => params[:name])
  image.delete
  redirect "/"
end
