require "rails_helper"

RSpec.describe "Songs endpoints" do
  before :each do
    @prince = Artist.create!(name: "Prince")
  end

  describe "happy paths" do

    it "can send a list of songs" do
      @prince.songs.create!(title: 'Raspberry Beret', length: 345, play_count: 34)
      @prince.songs.create!(title: 'Purple Rain', length: 524, play_count: 19)
      @prince.songs.create!(title: 'Kiss', length: 2301, play_count: 2300000)

      get "/api/v1/songs"

      expect(response).to be_successful

      songs = JSON.parse(response.body, symbolize_names: true)
      expect(songs.count).to eq(3)

      songs.each do |song|

        expect(song).to have_key(:id)
        expect(song[:id]).to be_an(Integer)

        expect(song).to have_key(:title)
        expect(song[:title]).to be_a(String)

        expect(song).to have_key(:length)
        expect(song[:length]).to be_an(Integer)

        expect(song).to have_key(:play_count)
        expect(song[:play_count]).to be_an(Integer)
      end
    end

    it "can get return about one song" do
      song_1 = @prince.songs.create!(title: 'Raspberry Beret', length: 345, play_count: 34)

      get "/api/v1/songs/#{song_1.id}"

      expect(response).to be_successful

      song_response = JSON.parse(response.body, symbolize_names: true)

      expect(song_response).to have_key(:id)
      expect(song_response[:id]).to eq(song_1.id)

      expect(song_response).to have_key(:title)
      expect(song_response[:title]).to eq(song_1.title)

      expect(song_response).to have_key(:length)
      expect(song_response[:length]).to eq(song_1.length)

      expect(song_response).to have_key(:play_count)
      expect(song_response[:play_count]).to eq(song_1.play_count)
    end

    it "can create a new song" do
      song_params = ({
        title: "Get Up Offa That Thing",
        length: 4567,
        play_count: 456445,
        artist_id: @prince.id
      })

      post "/api/v1/songs", params: song_params, as: :json
      created_song = Song.last

      expect(response).to be_successful
      expect(response.code).to eq("201")

      expect(created_song.title).to eq(song_params[:title])
      expect(created_song.length).to eq(song_params[:length])
      expect(created_song.play_count).to eq(song_params[:play_count])
      expect(created_song.artist).to eq(@prince)
    end

    it "can update an existing song" do
      song_1 = @prince.songs.create!(title: 'Raspberry Beret', length: 345, play_count: 34)

      song_update_params = {
        length: 323
      }

      patch "/api/v1/songs/#{song_1.id}", params: song_update_params, as: :json

      updated_song = Song.find(song_1.id)

      expect(response).to be_successful

      song_response = JSON.parse(response.body, symbolize_names: true)
      expect(song_response[:length]).to eq(song_update_params[:length])

      expect(updated_song.length).to eq(song_update_params[:length])
    end

    it "can destroy a song" do
      song_1 = @prince.songs.create!(title: 'Raspberry Beret', length: 345, play_count: 34)

      delete "/api/v1/songs/#{song_1.id}"

      expect(response).to be_successful
      #  Either of these options below can verify this song no longer exists
      expect(Song.count).to eq(0)
      expect(Song.find_by(id: song_1.id)).to be_nil
      expect { Song.find(song_1.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "sad paths" do
    it "will gracefully handle if a Song id doesn't exist" do
      get "/api/v1/songs/123489846278"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:message]).to eq("Couldn't find Song with 'id'=123489846278")
    end

    it "can create a new song" do
      song_params = ({
        title: "Get Up Offa That Thing",
        length: 4567,
        play_count: 456445,
        # artist_id: @prince.id
      })

      post "/api/v1/songs", params: song_params, as: :json
      created_song = Song.last

      data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.code).to eq("400")

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("400")
      expect(data[:errors].first[:message]).to eq("Validation failed: Artist must exist")
    end
  end
end