require 'json'

class Comment
  def initialize comment_json, user_json
    @comment = comment_json
    @user = user_json
  end

  def text
    @comment['body']['text']
  end

  def user
    @user['name']
  end

  def likes
    @comment['likecount']
  end

  def timestamp
    @comment['timestamp']['verbose']
  end

  def to_s
    "#{user}: #{text} (#{likes} likes)"
  end
end

class CommentsPage
  def initialize raw
    @json = JSON.parse(raw)
  end

  def comments
    raw = @json['jsmods']['require'][0][3][1]['comments']
    raw.map { |c| Comment.new(c, user_for(c['author'])) }
  end

  def profiles
    @json['jsmods']['require'][0][3][1]['profiles']
  end

  def user_for id
    profiles.find { |p| p['id'] == id }
  end
end

comments = []

Dir.glob("data/*.json") do |file|
  content = File.read(file)
  page = CommentsPage.new(content)
  comments.concat(page.comments)
end

def comments_leaderboard comments
  grouped = comments.group_by { |x| x.user }.map { |k, v| { name: k, count: v.count } }
  sorted = grouped.sort_by { |x| x[:count] }
  sorted.reverse.first(10)
end

def likes_leaderboard comments
  #grouped = comments.group_by { |x| x.likes }.map { |k, v| { name: k, count: v.count } }
  sorted = comments.sort_by { |x| x.likes }
  sorted.reverse.first(10)
end

puts "MOST COMMENTS"
puts comments_leaderboard(comments)
puts
puts "MOST LIKES"
puts likes_leaderboard(comments)
