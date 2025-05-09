# frozen_string_literal: true

require 'cgi'

# メモ
class Memo
  attr_accessor :id

  def initialize(id, name, content = '')
    @id = id.to_i
    @name = name
    @content = content
  end

  def name(escape_html: true)
    return CGI.escape_html(@name) if escape_html

    @name
  end

  def content(escape_html: true)
    return CGI.escape_html(@content) if escape_html

    @content
  end

  def edit(name, content = '')
    @name = name
    @content = content
  end

  def to_h
    { id: @id, name: @name, content: @content }
  end
end
