# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create admin user
User.create(nameFirst: 'Nemo', nameLast: 'Nihili', nameNickname: 'Admin', loginUsername: 'admin', password: 'admin', contactEmail: 'admin@admin.admin', useNickname: true)
