# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.require

enable :sessions

WeiboOAuth2::Config.api_key = ENV['KEY']
WeiboOAuth2::Config.api_secret = ENV['SECRET']
WeiboOAuth2::Config.redirect_uri = ENV['REDIR_URI']

get '/' do
  client = CsdnOAuth2::Client.new
  if session[:uid] && !client.authorized?
    token = client.get_token_from_hash({:access_token => session[:token], :expires_at => session[:expires_at]})
    unless token.validated?
      reset_sessions
      redirect '/login'
      return
    end
    @account = client.account.get_info
  end
  slim :index
end

get '/login' do
  client = CsdnOAuth2::Client.new
  redirect client.authorize_url
end

get '/callback' do
   client = CsdnOAuth2::Client.new
   res = client.auth_code.get_token(params[:code])
   session[:token] = res.token
   session[:expires_at] = res.expires_at
   session[:uid] = res.params['uid']
   redirect '/'
end

get '/logout' do
  reset_session
  redirect '/'
end

helpers do
  def reset_session
    session[:uid] = nil
    session[:token] = nil
    session[:expires_at] = nil
  end
end