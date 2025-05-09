# frozen_string_literal: true

require 'json'
require 'singleton'
require 'pg'
require_relative 'memo'

MEMO_JSON_PATH = './memos.json'

# メモのリスト
class MemoList
  include Singleton

  attr_reader :memos

  def initialize
    @conn = PG.connect(dbname: 'webmemo')
    @conn.exec('SELECT * FROM memos') do |result|
      @memos = result.map do |row|
        Memo.new(*row.values_at('id', 'name', 'content'))
      end
    end
    @memos.sort! { |a, b| a.id <=> b.id }
    @current_id = @memos.empty? ? 0 : @memos[-1].id
  end

  def get_memo(id)
    @memos.find do |memo|
      memo.id == id.to_i
    end
  end

  def add(name, content = '')
    id = new_id
    new_memo = Memo.new(id, name, content)
    @memos << new_memo

    query = 'INSERT INTO Memos (id, name, content) VALUES($1::int, $2::varchar, $3::text);'
    @conn.exec_params(query, [new_memo.id, @conn.escape(new_memo.name), @conn.escape(new_memo.content)])

    new_memo
  end

  alias new_memo add

  def edit(id, name, content = '')
    memo = get_memo(id)
    memo.edit(name, content)

    query = 'UPDATE Memos SET name = $1::varchar, content= $2::text WHERE id = $3::int'
    @conn.exec_params(query, [@conn.escape(memo.name), @conn.escape(memo.content), memo.id])
    memo
  end

  def delete(id)
    @memos.delete_if do |memo|
      memo.id == id.to_i
    end
    query = 'DELETE FROM Memos WHERE id = $1::int'
    @conn.exec_params(query, [id])
  end

  private

  def new_id
    @current_id += 1
    @current_id
  end
end
