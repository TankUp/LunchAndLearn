require './db_init'
require './models'

ilya =  Person.new(slack_name: 'Ilya')
stan =  Person.new(slack_name: 'Stanislav')
plmn =  Person.new(slack_name: 'Plamen')

vid = Video.new(url: 'tank')
table_tennis_room = Venue.new(name: 'TABLE TENNIS :)')

ev = Event.new(week: 1)
ev.save!
ev.people << stan