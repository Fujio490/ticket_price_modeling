require 'time'
require 'holiday_japan'

inputs = []
ticket_array = []

# データ入力、フォーマット整理
# [日時,"名前","グループ"]
File.foreach("ticket.txt") do |f|
    inputs.push(f.chomp)
end
inputs.each do |f|
    f.delete!("\"")
    ticket_array.push(f.split(","))
end
ticket_array.each do |f|   
    f[0] = Time.parse(f[0])
end

# チケットインスタンス
class Ticket
    attr_accessor :date, :name, :group, :price

    def weekdays
        unless date.saturday? || date.sunday? || HolidayJapan.check(date)
            true
        else
            false
        end
    end
    def late_time
        true if date.hour >= 20
    end
    def cinema_day
        true if date.day == 1
    end

    def initialize(properties)
        date = properties[0]
        name = properties[1]
        group = properties[2]
        
        @date = date
        @name = name
        @group = group

        price = 1800

        # 料金の決定
        case group
        when "シニア（70才以上）" then
            price -= 700
        when "中・高校生", "幼児（3才以上）・小学生", "障がい者（学生以上）" then
            price -= 800
        when "障がい者（高校以下）" then
            price -= 900
        when "シネマシティズン（60才以上）" then
            price -= 800
        when "シネマシティズン" then
            price -= 500
            if late_time || weekdays
                price -= 300
            elsif cinema_day
                price -= 200
            end
        when "一般" then
            if cinema_day
                price -= 700
            elsif late_time
                price -= 500
            end
        when "学生（大・専）" then
            price -= 300
            if cinema_day
                price -= 400
            elsif late_time
                price -= 200
            end
        end
        @price = price
    end
end

# 集計
def summary(*ticket_array)
    total = 0
    ticket_array.each do |properties|
        ticket = Ticket.new(properties)
        total += ticket.price
    end
    puts "売上: #{total}円"
end
def earn_by_name(cinema_name, *ticket_array)
    total = 0
    ticket_array.each do |properties|
        ticket = Ticket.new(properties)
        total += ticket.price if ticket.name == cinema_name
    end
    puts "#{cinema_name}: #{total}円"
end
def earn_by_group(group_name, *ticket_array)
    total = 0
    ticket_array.each do |properties|
        ticket = Ticket.new(properties)
        total += ticket.price if ticket.group == group_name
    end
    puts "#{group_name}: #{total}円"
end

puts "▼サマリー"
summary(*ticket_array)
puts "\n"

puts "▼作品別売上"
earn_by_name("スター・ウォーズ",*ticket_array)
earn_by_name("ジュマンジ", *ticket_array)
earn_by_name("ジョーカー", *ticket_array)
earn_by_name("ルパン三世", *ticket_array)
earn_by_name("アナと雪の女王", *ticket_array)
puts "\n"

puts "▼料金タイプ別売上"
earn_by_group("シネマシティズン（60才以上）",*ticket_array)
earn_by_group("幼児（3才以上）・小学生",*ticket_array)
earn_by_group("シニア（70才以上）",*ticket_array)
earn_by_group("シネマシティズン",*ticket_array)
earn_by_group("学生（大・専）",*ticket_array)
earn_by_group("中・高校生",*ticket_array)
earn_by_group("一般",*ticket_array)
earn_by_group("障がい者（学生以上）",*ticket_array)
earn_by_group("障がい者（高校以下）",*ticket_array)