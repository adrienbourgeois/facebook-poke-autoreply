
#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'highline/import'

case ENV['RUBY_ENV']
  when 'production' then
    Bundler.require(:default)
  else
    Bundler.require(:default, :development)
end

class Poker
  attr_reader :agent

  def initialize(email, pass)
    puts "a"
    @agent = Mechanize.new
    @agent.user_agent_alias = 'iPhone'
    puts "b"
    self.agent.get('http://m.facebook.com')
    puts agent.page.title
    self.login(email, pass)
  end

  def login(email, pass)
    form = self.agent.page.form_with(method: 'POST')
    form.email, form.pass = email, pass

    self.agent.submit(form)
    self.agent.get('http://m.facebook.com/pokes')
    puts self.agent.page.title
  end

  def logout
    self.agent.page.link_with(text: /logout/).click
  end

  def poke_back_everybody
    self.agent.get('http://m.facebook.com/pokes')
    self.agent.page.search("[class='pokerName']").each do |link|
      puts "#{link.inner_text} poked back"
    end

    links = self.agent.page.links_with(text: 'Poke back')
    links.each{ |l| l.click }
  end

end

print "Put your mail: "
mail = gets.chomp
#pass = gets.chomp
pass = ask("Password: ") { |q| q.echo = "" }

print "Enter the minimum number of seconds between two pokes (has to be greater than 10): "
delay = gets.chomp.to_i
delay = 10 if delay == nil || delay < 10


Poker.new(mail, pass).tap do |poker|
  while true do
    poker.poke_back_everybody
    sleep(5)
  end
end

