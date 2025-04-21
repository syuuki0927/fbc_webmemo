require 'rubygems'

require 'sinatra'
require 'sinatra/reloader'
require 'json'

MEMO_JSON_PATH = './memos.json'.freeze

memos = if File.exist?(MEMO_JSON_PATH)
          JSON.load_file(MEMO_JSON_PATH)
        else
          JSON.parse('{"memos": []}')
        end

get ['/', '/memos'] do
  @memo_bullets = memos['memos'].map.with_index do |memo, memo_index|
    "<li><a href=\'/memos/#{memo_index}\'>#{memo['name']}</a></li>"
  end
  @memo_bullets = "<ul>#{@memo_bullets.join}</ul>"
  erb :index, layout: :default_layout
end

get '/memos/new' do
  erb :new, layout: :default_layout
end

post '/memos/new' do
  memos['memos'] << { 'name' => params[:name], 'content' => params[:content] }

  store_json(memos)
  # 追加したメモの表示ページへ遷移
  redirect "/memos/#{memos['memos'].length - 1}"
end

get '/memos/*/edit' do |memo_id|
  redirect_ooi_memoid(memo_id, memos)

  @post_uri = "/memos/#{memo_id}/edit"
  @name = memos['memos'][memo_id.to_i]['name']
  @content = memos['memos'][memo_id.to_i]['content']

  erb :edit, layout: :default_layout
end

patch '/memos/*/edit' do |memo_id|
  memos['memos'][memo_id.to_i]['name'] = params[:name]
  memos['memos'][memo_id.to_i]['content'] = params[:content]

  store_json(memos)
  redirect "/memos/#{memo_id}"
end

get '/memos/*' do |memo_id|
  redirect_ooi_memoid(memo_id, memos)

  @name = memos['memos'][memo_id.to_i]['name']
  @content = memos['memos'][memo_id.to_i]['content']
  @edit_uri = "\'/memos/#{memo_id}/edit\'"
  @delete_uri = "\'/memos/#{memo_id}\'"

  erb :memos, layout: :default_layout
end

delete '/memos/*' do |memo_id|
  memos['memos'].delete_at(memo_id.to_i)

  store_json(memos)
  redirect '/memos'
end

get ['*', '/ror-not-found'] do
  '404 not found'
end

def memo_existing?(num, memos)
  return true if num =~ /^[0-9]+$/ && num.to_i >= 0 && num.to_i < memos['memos'].length

  false
end

# 範囲外（out of index）のメモIDが指定された場合に404にリダイレクト
def redirect_ooi_memoid(num, memos)
  return if memo_existing?(num, memos)

  redirect '/404-not-found'
end

def store_json(memos)
  json_str = JSON.generate(memos)
  File.open(MEMO_JSON_PATH, 'w') do |f|
    f.write(json_str)
  end
end
