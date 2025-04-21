require 'rubygems'

require 'sinatra'
require 'sinatra/reloader'

require_relative './memo'

memo_list = [Memo.new('memo 1'), Memo.new('memo 2'), Memo.new('memo 3')]

get ['/', '/memos'] do
  @memo_bullets = memo_list.map.with_index do |memo, memo_index|
    "<li><a href=\'/memos/#{memo_index}\'>#{memo.name}</a></li>"
  end
  @memo_bullets = "<ul>#{@memo_bullets.join}</ul>"
  erb :index, layout: :default_layout
end

get '/memos/new' do
  erb :new, layout: :default_layout
end

post '/memos/new' do
  new_memo = Memo.new(params[:name], params[:content])
  memo_list << new_memo

  # 追加したメモの表示ページへ遷移
  redirect "/memos/#{memo_list.length - 1}"
end

get '/memos/*/edit' do |memo_id|
  redirect_ooi_memoid(memo_id, memo_list)

  @post_uri = "/memos/#{memo_id}/edit"
  @name = memo_list[memo_id.to_i].name
  @content = memo_list[memo_id.to_i].content

  erb :edit, layout: :default_layout
end

post '/memos/*/edit' do |memo_id|
  memo_list[memo_id.to_i].name = params[:name]
  memo_list[memo_id.to_i].content = params[:content]

  redirect "/memos/#{memo_id}"
end

get '/memos/*' do |memo_id|
  redirect_ooi_memoid(memo_id, memo_list)

  @name = memo_list[memo_id.to_i].name
  @content = memo_list[memo_id.to_i].content
  @edit_uri = "\'/memos/#{memo_id}/edit\'"
  @delete_uri = "\'/memos/#{memo_id}\'"

  erb :memos, layout: :default_layout
end

delete '/memos/*' do |memo_id|
  memo_list.delete_at(memo_id.to_i)

  redirect '/memos'
end

get ['*', '/ror-not-found'] do
  '404 not found'
end

def memo_existing?(num, memo_list)
  return true if num =~ /^[0-9]+$/ && num.to_i >= 0 && num.to_i < memo_list.length

  false
end

# 範囲外（out of index）のメモIDが指定された場合に404にリダイレクト
def redirect_ooi_memoid(num, memo_list)
  return if memo_existing?(num, memo_list)

  redirect '/404-not-found'
end
