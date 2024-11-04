class Api::V1::SongsController < ApplicationController
  def index
    render json: SongSerializer.format_songs(Song.all)
  end

  def show
    begin
      render json: SongSerializer.format_song(Song.find(params[:id]))
    rescue ActiveRecord::RecordNotFound => error
      render json: {
        errors: [
          {
            status: "404",
            message: error.message
          }
        ]
      }, status: 404 #alternative status: :not_found
    end
  end

  def create
    begin
      song = Song.create!(song_params)
      render json: song, status: 201
    rescue ActiveRecord::RecordInvalid => error
      render json: {
        errors: [
          {
            status: "422",
            message: error.message
          }
        ]
      }, status: 422 #alternative status: :not_found
    end
  end

  def update
    song = Song.find(params[:id])
    song.update(song_params)

    render json: SongSerializer.format_song(song)
  end

  def destroy
    song = Song.find(params[:id])
    song.destroy

    head :no_content
  end

  private

  def song_params
    params.require(:song).permit(:song, :title, :length, :play_count, :artist_id)
  end
end