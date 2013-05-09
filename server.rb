require 'sinatra'
require 'json'
require 'git'
require 'jekyll'
require 'oauth2'

post '/' do

  dir = './tmp/jekyll'
  name = "JekyllBot"
  email = "godamonra+bot@gmail.com"
  username = ENV['GITHUB_USER'] || ''
  password = ENV['GITHUB_PASS'] || ''

  FileUtils.rm_rf dir

  push = JSON.parse(params[:payload])
  if push["commits"].first["author"]["name"] == name
    puts "This is just the callback from JekyllBot's last commit... aborting."
    return
  end

  url = push["repository"]["url"] + ".git"
  url["https://"] = "https://" + username + ":" + password + "@"

  puts "cloning into " + url
  g = Git.init(dir)
  g.add_remote('origin', url)
  g.pull

  options = {}
  options["safe"] = false
  options["source"] = dir
  options["destination"] = File.join( dir, '_site')
  options["plugins"] = File.join( dir, '_plugins')
  options = Jekyll.configuration(options)
  site = Jekyll::Site.new(options)

  puts "starting to build in " + dir
  begin
    site.process
  rescue Jekyll::FatalException => e
    puts e.message
    FileUtils.rm_rf dir
    exit(1)
  end

  puts "succesfully built; commiting..."
  begin
    g.config('user.name', name)
    g.config('user.email', email)
    puts g.commit_all( "[JekyllBot] Building plugin-based files")
  rescue Git::GitExecuteError => e
    puts e.message
  else
    puts "pushing"
    puts g.push
    puts "pushed"
  end

  puts "cleaning up."
  FileUtils.rm_rf dir

  puts "done"

end

def new_client
  OAuth2::Client.new(ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], :site => 'https://github.com',
    :authorize_path => '/login/oauth/authorize', :access_token_path => '/login/oauth/access_token')
end

get "/" do
  %(<p>Update the <code>#new_client</code> method in the sinatra app and <a href="/auth/github">try to authorize</a>.</p>)
end

# access this to request a token from facebook.
get '/auth/github' do
  url = new_client.auth_code.authorize_url(
    :redirect_uri => redirect_uri,
    :scope => 'repo'
  )
  puts "Redirecting to URL: #{url.inspect}"
  redirect url
end

# If the user authorizes it, this request gets your access token
# and makes a successful api call.
get '/auth/github/callback' do
  begin
    access_token = new_client.auth_code.get_access_token(params[:code], :redirect_uri => redirect_uri)
    user = JSON.parse(access_token.get('https://api.github.com/user').body).fetch('login')
    "<p>Your OAuth access token: #{access_token.token}</p><p>Your extended profile data:\n#{user.inspect}</p>"
  rescue OAuth2::HTTPError
    %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
  end
end

def redirect_uri(path = '/auth/github/callback', query = nil)
  uri = URI.parse(request.url)
  uri.path  = path
  uri.query = query
  uri.to_s
end
