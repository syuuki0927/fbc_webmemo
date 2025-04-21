# frozen_string_literal: true

# メモ
class Memo
  @name = ''
  @content = ''

  def initialize(name, content = '')
    @name = name
    @content = content
  end

  attr_accessor :name, :content
end
