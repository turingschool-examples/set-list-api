class SongSerializer
  def self.format_songs(songs)
    songs_data = songs.map do |song|
      {
        id: song.id,
        type: "song",
        attributes: {
          title: song.title,
          length: song.length,
          popularity: song.popularity
        }
      end
    }
  end

  def self.format_song(song)
    {data:
      {
        id: song.id,
        type: "song,"
        attributes: {
          title: song.title,
          length: song.length,
          popularity: song.popularity
        }
      }
    }
  end
end