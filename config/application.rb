require 'sinatra'
require "sinatra/activerecord"

CONFIG = HashWithIndifferentAccess.new YAML::load_file("config/config.yml")
set :database, {
  adapter: "sqlite3",
  database: "db/bdwm_subser.sqlite3"
}
set :port, 3000
set :views, File.dirname(__FILE__) + "/../views"
I18n.enforce_available_locales = false

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
  if params[:email]
    @subscriptions = Subscription.where(email: params[:email]).includes(:board)
  else
    @subscriptions = Subscription.all.includes(:board)
  end
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
  if params[:email] and params[:id] and sub = Subscription.find_by(params)
    sub.destroy
    redirect "/?email=#{params[:email]}"
  else
    erb "错误"
  end
end
