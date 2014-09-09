require 'sinatra'
require "sinatra/activerecord"

CONFIG = HashWithIndifferentAccess.new YAML::load_file("config.yml")
set :database, {
  adapter: "sqlite3",
  database: "db/bdwm_subser.sqlite3"
}
set :port, 3000

class Board < ActiveRecord::Base
  has_many :subscriptions, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
class Subscription < ActiveRecord::Base
  belongs_to :board
  validates :board, :keywords, :email, presence: true
  validates :email, format: /\A\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\Z/
end

# index
get "/" do
  @subscriptions = Subscription.all.includes(:board)
  erb :index
end
# create
post "/" do
  board = Board.where("lower(name) = ?", params[:board].downcase).first
  if board.nil?
    erb "找不到对应版面"
  elsif (sub = Subscription.new(board: board,
                                keywords: params[:keywords],
                                email: params[:email],
                                ip: request.ip)).save
    redirect "/"
  else
    erb "无法创建订阅，原因：#{sub.errors.full_messages.join(", ")}"
  end
end
# destroy
get "/delete" do
  if params[:id] and params[:email] and sub = Subscription.find_by(params)
    sub.destroy
    erb "您已成功退订"
  else
    erb "错误"
  end
end
