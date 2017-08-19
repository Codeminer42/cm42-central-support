require 'rails_helper'

describe Central::Support::Discord do
  let(:discord) { Central::Support::Discord.new("http://foo.com", "bot") }

  context '#payload' do
    it 'returns a params formatted payload' do
      expect(discord.payload("Hello World")).to eq(username: "bot", content: "Hello World")
    end
  end

  context '#send' do
    it 'triggers a HTTP POST to send payload' do
      expect(Rails.env).to receive(:development?).and_return(false)
      expect(Net::HTTP).to receive(:post_form)
      discord.send("hello")
    end
  end
end
