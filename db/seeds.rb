# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.create!(nickname: "Joel", email: "joel@ga.com", password:"password")
User.create!(nickname: "Ben", email: "ben@ga.com", password:"password")
Match.new_match!(1,2)
