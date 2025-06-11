# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Fakerライブラリの日本語設定
require 'faker'
Faker::Config.locale = :ja

# =================================================================
# 実行のたびに古いデータを全削除する
# =================================================================
puts '古いデータを削除しています...'
Schedule.destroy_all
User.destroy_all
puts '古いデータの削除が完了しました。'
puts '---------------------------------'

# =================================================================
# ユーザーのテストデータを作成
# =================================================================
puts 'ユーザーの作成を開始します...'

# 1. ログインして手動テストするための固定ユーザー
main_user = User.create!(
  name: 'テストユーザー',
  email: 'test@example.com',
  password: 'password',
  password_confirmation: 'password'
)
puts "固定ユーザーを作成しました: #{main_user.name} (email: #{main_user.email})"

# 2. ランダムなユーザーを5人作成
other_users = []
5.times do
  user = User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password',
    password_confirmation: 'password'
  )
  other_users << user
  puts "ランダムユーザーを作成しました: #{user.name}"
end
puts 'ユーザーの作成が完了しました。'
puts '---------------------------------'

# =================================================================
# スケジュールのテストデータを作成
# =================================================================
puts 'スケジュールの作成を開始します...'

# 固定ユーザーに紐づくスケジュールを20個作成
20.times do |i|
  # 開始時刻をランダムに設定 (-10日 ~ +10日)
  start_time = Faker::Time.between(from: 10.days.ago, to: 10.days.from_now)
  
  # statusをランダムに設定 (0:未着手, 1:進行中, 2:達成, 3:未達成)
  # 過去の予定は「達成」か「未達成」に、未来の予定は「未着手」にする
  status = if start_time < Time.current
             [2, 3].sample
           else
             0
           end

  Schedule.create!(
    user: main_user, # 固定ユーザーに紐づける
    title: "タスク No.#{i + 1}: #{Faker::Lorem.sentence(word_count: 3)}",
    description: Faker::Lorem.paragraph(sentence_count: 2),
    start_time: start_time,
    end_time: start_time + rand(1..5).hours, # 開始時刻の1~5時間後を終了時刻に
    status: status,
    priority: rand(1..10), # 優先度を1~10でランダムに設定
    location: ['自宅', 'オフィス', 'カフェ', nil].sample # 場所をランダムに設定
  )
end
puts "固定ユーザー用のスケジュールを20件作成しました。"

# ランダムユーザーに紐づくスケジュールをそれぞれ5個ずつ作成
other_users.each do |user|
  5.times do
    start_time = Faker::Time.between(from: 5.days.ago, to: 5.days.from_now)
    Schedule.create!(
      user: user,
      title: Faker::ProgrammingLanguage.name + "の学習",
      description: "チュートリアルを進める",
      start_time: start_time,
      end_time: start_time + 2.hours,
      status: start_time < Time.current ? [2, 3].sample : 0,
      priority: rand(1..5)
    )
  end
  puts "#{user.name}用のスケジュールを5件作成しました。"
end

puts '---------------------------------'
puts 'すべてのSeedデータの作成が完了しました！'