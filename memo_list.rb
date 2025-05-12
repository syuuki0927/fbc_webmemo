# frozen_string_literal: true

require 'singleton'
require 'pg'
require_relative 'memo'

# メモのリスト
class MemoList
  include Singleton

  attr_reader :memos

  def initialize
    @conn = PG.connect(dbname: 'webmemo')
    @conn.exec('SELECT * FROM memos ORDER BY id') do |result|
      @memos = result.map do |row|
        Memo.new(*row.values_at('id', 'name', 'content'))
      end
    end
  end

  def get_memo(id)
    @memos.find do |memo|
      memo.id == id.to_i
    end
  end

  def add(name, content = '')
    query = "INSERT INTO Memos (id, name, content) VALUES(nextval('memos_seq'), $1, $2) RETURNING id;"
    @conn.exec_params(query, [name, content]) do |result|
      result.map do |row|
        new_memo = Memo.new(row['id'], name, content)
        @memos << new_memo
      end
    end

    @memos[-1]
  end

  alias new_memo add

  def edit(id, name, content = '')
    memo = get_memo(id)
    memo.edit(name, content)

    query = 'UPDATE Memos SET name = $1, content= $2 WHERE id = $3'
    @conn.exec_params(query, [memo.name, memo.content, memo.id])
    memo
  end

  def delete(id)
    @memos.delete_if do |memo|
      memo.id == id.to_i
    end
    query = 'DELETE FROM Memos WHERE id = $1'
    @conn.exec_params(query, [id])
  end
end
