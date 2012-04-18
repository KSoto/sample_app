namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(:name => "Example User",
                         :email => "example0@railstutorial.org",
                         :password => "foobar",
                         :password_confirmation => "foobar",
                         :public => true)
    admin.toggle!(:admin)
    50.times do |n|
      name  = Faker::Name.name
      email = "example1-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password,
                   :public => true)
    end
    50.times do |n|
      name  = Faker::Name.name
      email = "example2-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password,
                   :public => false)
    end
  end
end