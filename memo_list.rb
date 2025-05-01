# frozen_string_literal: true

require 'json'
require 'singleton'
require_relative 'memo'

MEMO_JSON_PATH = './memos.json'

# メモのリスト
class MemoList
  include Singleton

  attr_reader :memos

  def initialize
    json_parsed = if File.exist?(MEMO_JSON_PATH)
                    JSON.load_file(MEMO_JSON_PATH,
                                   { symbolize_names: true })
                  else
                    JSON.parse('[]')
                  end
    @memos = json_parsed.map do |memo|
      Memo.new(*memo.values_at(:id, :name, :content))
    end
    @current_id = @memos.empty? ? 0 : @memos[-1].id
  end

  def get_memo(id)
    @memos.find do |memo|
      memo.id == id.to_i
    end
  end

  def add(name, content = '')
    new_memo = Memo.new(new_id, name, content)
    @memos << new_memo
    store_json
    new_memo
  end

  alias new_memo add

  def edit(id, name, content = '')
    memo = get_memo(id)
    memo.edit(name, content)
    store_json
    memo
  end

  def delete(id)
    @memos.delete_if do |memo|
      memo.id == id.to_i
    end
    store_json
  end

  private

  def new_id
    @current_id += 1
    @current_id
  end

  def store_json
    memos_hash = @memos.map(&:to_h)
    json_str = JSON.generate(memos_hash)
    File.write(MEMO_JSON_PATH, json_str)
  end
end
