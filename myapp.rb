# frozen_string_literal: true

require 'rubygems'

require 'sinatra'
require 'sinatra/reloader'
require_relative 'memo_list'

MEMO_JSON_PATH = './memos.json'

memos = MemoList.instance

get '/' do
  @memos = memos.memos
  erb :index, layout: :default_layout
end

get '/memos/new' do
  erb :new, layout: :default_layout
end

post '/memos' do
  new_memo = memos.new_memo(params[:name], params[:content])

  redirect "/memos/#{new_memo.id}"
end

get '/memos/:memo_id/edit' do |memo_id|
  @memo = memos.get_memo(memo_id)
  raise Sinatra::NotFound if @memo.nil?

  erb :edit, layout: :default_layout
end

patch '/memos/:memo_id' do |memo_id|
  memos.edit(memo_id, params[:name], params[:content])

  redirect "/memos/#{memo_id}"
end

get '/memos/:memo_id' do |memo_id|
  @memo = memos.get_memo(memo_id)
  raise Sinatra::NotFound if @memo.nil?

  erb :memos, layout: :default_layout
end

delete '/memos/:memo_id' do |memo_id|
  memos.delete(memo_id)

  redirect '/'
end

get '*' do
  raise Sinatra::NotFound
end
