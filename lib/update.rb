require "open-uri"
require "nokogiri"
require "time"
require "pony"

def update_board(board)
  content = open("http://www.bdwm.net/bbs/bbstop.php?board=#{board.name}").read.encode("UTF-8", "GB18030")
  recent = nil
  result = []
  Nokogiri::HTML(content).css(".body tr").to_a.last(20).reverse.each do |tr|
    author = tr.elements[1].content.strip
    time = tr.elements[2].content.strip
    link = tr.elements[3].elements[0]
    thread_id = link["href"].match(/\d+\Z/)[0]
    title = link.content.strip

    recent = thread_id if recent.nil?
    break if thread_id == board.last_id
    result << [thread_id, author, time, title]
  end
  if !result.empty?
    board.subscriptions.each do |sub|
      @to_send[sub.email] ||= []
      result.each do |result|
        thread_id, author, time, title = result
        sub.keywords.split(" ").each do |keyword|
          if title.match keyword
            @to_send[sub.email] << [board.name, keyword, thread_id, author, time, title]
          end
        end
      end
    end
    board.update(last_id: recent)
  end
end

@to_send = {}
def send_all_mail
  @to_send.each do |email, contents|
    next if contents.empty?
    body = ERB.new(File.read("views/email.erb")).result(binding)
    Pony.mail to: email,
              from: "BDWM 关键词订阅 <#{CONFIG["smtp"]["user_name"]}>",
              subject: "[BDWM 订阅] #{contents.map(&:first).uniq.join(", ")} 版面提醒",
              charset: "UTF-8",
              html_body: body,
              via: :smtp,
              via_options: CONFIG["smtp"].symbolize_keys
  end
end

Subscription.select(:board_id).distinct.includes(:board).map(&:board).each do |board|
  update_board(board)
end
send_all_mail
