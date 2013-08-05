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

  def initialize
    @agent = Mechanize.new
    @agent.get('http://m.facebook.com/')
    puts @agent.page.title
  end
  
  def login(email, pass)
    form = @agent.page.form_with(method: 'POST')
    form.email = email
    form.pass = pass
    @agent.submit(form)
    @agent.get('http://m.facebook.com/pokes')
    puts @agent.page.title
  end
    
  def logout
    @agent.page.link_with(text: /logout/).click
  end
    
  def poke_back_everybody
    @agent.get('http://m.facebook.com/pokes') #refresh the page
    
    #get the names of the pokers:
    @agent.page.search("[class='pokerName']").each do |link|
      puts "#{link.inner_text} poked back"
    end
    
    #poke back:
    links = @agent.page.links_with(text: 'Poke back')
    links.each{ |l| l.click }
  end

end

EMAIL = "EMAIL"
PASS = "PASSWORD"
poker = Poker.new
poker.login(EMAIL,PASS)
while true do
  poker.poke_back_everybody
  sleep(5)
end