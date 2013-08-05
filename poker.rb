#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

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
    self.agent.get('http://m.facebook.com/pokes') #refresh the page
    #get the names of the pokers:
    self.agent.page.search("[class='pokerName']").each do |link|
      puts "#{link.inner_text} poked back"
    end

    #poke back:
    links = self.agent.page.links_with(text: 'Poke back')
    links.each{ |l| l.click }
  end

end

raise 'please provide ENV_EMAIL & ENV_PASS' unless ENV['ENV_EMAIL'] && ENV['ENV_PASS']

Poker.new(ENV['ENV_EMAIL'], ENV['ENV_PASS']).tap do |poker|
  while true do
    poker.poke_back_everybody
    sleep(5)
  end
end
