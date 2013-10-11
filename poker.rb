
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
    @agent = Mechanize.new
    @agent.user_agent_alias = 'iPhone'
    self.agent.get('http://m.facebook.com')
    puts 'Facebook is unreachable' unless agent.page.title == 'Welcome to Facebook'
    self.login(email, pass)
  end

  def login(email, pass)
    form = self.agent.page.form_with(method: 'POST')
    form.email, form.pass = email, pass

    self.agent.submit(form)
    self.agent.get('http://m.facebook.com/pokes')
    puts 'Impossible to login. Try to login on facebook website to check everything is ok' unless self.agent.page.title == 'Pokes'
  end

  def logout
    self.agent.page.link_with(text: /logout/).click
  end

  def poke_back_everybody
    self.agent.get('http://m.facebook.com/pokes')
    self.agent.page.search("[class='_5hn8']").each do |link|
      div_text = link.inner_text
      if div_text[-10..div_text.size] == 'poked you.'
        puts "#{div_text[0..-12]} poked back"
      end
    end

    links = self.agent.page.links_with(text: 'Poke back')
    links.each{ |l| l.click }
  end

end

print "Put your mail: "
mail = gets.chomp
pass = ask("Password: ") { |q| q.echo = "" }

print "Enter the minimum number of seconds between two pokes (has to be greater than 10): "
delay = gets.chomp.to_i
delay = 10 if delay == nil || delay < 10


Poker.new(mail, pass).tap do |poker|
  while true do
    poker.poke_back_everybody
    sleep(delay)
  end
end

