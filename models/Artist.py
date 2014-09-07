from bson.objectid import ObjectId
from heapq import heappush, nlargest
import uuid


class Artist_Filter(object):
    """ Used to retrieve information about artists.
    """

    def __init__(self):
        """ Inits the Filter
        """
        self.songs = {}
        self.artists = {}

    def get_songs(self, request, criteria, fields):
        """ Gets all songs associated with an artist,
        although you can get anything else with it.
        """
        artist_list = {}
        artists = request.db['artists'].find(criteria, fields)
        for artist in artists:
            if artist['name'] not in artist_list.keys():
                artist_list[artist['name']] = {
                    'id': artist['_id'], 'list': []}

            if 'songs' in artist.keys():
                for song in artist['songs']:
                    artist_list[artist['name']]['list'].append({
                        'song_id': song['song_id'],
                        'song_title': song['title'],
                        'artist_id': artist['_id']})

        self.songs = artist_list

    def get_artists_only(self, request, fields):
        """ Returns a dictionary of artists - no songs
        """
        artists = request.db['artists'].find({}, fields)
        for artist in artists:
            if artist['url-name'] not in self.artists:
                count = request.db['concerts'].find({
                    'artist': artist['name']}).count()
            self.artists[artist['url-name']] = {
                'name': artist['name'],
                'show_count': count}


class Artist(object):
    """ Holds all artist information.
    """

    def __init__(self, artist, flag, request):
        """ Initializes artist information.
        """
        self.artist = artist
        self.song = {'title': '', 'song_id': '', 'lyrics': ''}
        if flag == 'AUTOCOMPLETE':
            self.songs = self.find_songs(request)

    def get_latest_concerts(self, criteria, fields,  limit, request):
        """ Gets the latest sconcerts for this artist
        """
        self.latest_concerts = []
        concerts = request.db['concerts'].find(
            criteria, fields).limit(limit).sort([('date',  -1)])
        for concert in concerts:
            self.latest_concerts.append(concert)

    def find_songs(self, request):
        """ Finds songs that correspond to a given artist
        """
        artist = request.db['artists'].find_one(
            {'name': {'$regex': self.artist}})
        options = ''
        if artist is not None:
            if 'songs' in artist.keys():
                for song in artist['songs']:
                    options += ('<option value="%s">%s</option>' %
                                (song['song_id'], song['title']))
            self.artist = artist['name']
        return options

    def add_or_edit_song(self, request, song):
        """ Adds a song to the database or edits one
        """
        save_dict = {key: song[key] for key in ('title', 'lyrics')}
        # Indicates that this is a new song and needs to be treated as such
        save_dict['song_id'] = song['update']
        if song['update'] == 'NA':
            save_dict['song_id'] = str(uuid.uuid1())

        artist = request.db['artists'].find_one(
            {'_id': ObjectId(song['artist_id'])})

        # Check for existing songs- if matched, just update that one
        if 'songs' in artist:
            for song in artist['songs']:
                if song['song_id'] == save_dict['song_id']:
                    song['title'] = save_dict['title']
                    song['lyrics'] = save_dict['lyrics']
                    request.db['artists'].save(artist)
                    return
        else:
            artist['songs'] = []

        artist['songs'].append(save_dict)
        request.db['artists'].save(artist)

    def delete_song(self, request, song):
        """ Deletes an existing song.
        """
        request.db['artists'].update(
            {'_id': ObjectId(song['artist_id'])},
            {'$pull': {'songs': {'song_id': song['song_id']}}})

    def get_song(self, request, artist_id, song_id):
        """ Gets a song
        """
        artist = request.db['artists'].find_one(
            {'_id': ObjectId(self.artist)},
            {'songs': 1})
        for song in artist['songs']:
            if song['song_id'] == song_id:
                self.song = song
                return

    def get_song_url(self, request, artist_id, song_id, limit):
        """ Gets a song from url friendliness
        """
        artist = request.db['artists'].find_one({
            'url-name': artist_id})
        self.artist = artist['name']
        for song in artist['songs']:
            if song['song_id'] == song_id:
                self.song = song
                break

        self.song['count'] = request.db['concerts'].find(
            {'setlist_array.song_id': song_id}).count()

        self.song_at_concerts = []
        concerts_played_at = request.db['concerts'].find(
            {'setlist_array.song_id': song_id},
            {'date': 1, 'venue': 1, 'concert_id': 1}
        ).limit(limit).sort([('date',  -1)])
        for concert in concerts_played_at:
            self.song_at_concerts.append(concert)

    def get_artist_limit_songs(self, request, criteria,  fields, limit):
        """ Gets an artist and their top tracks
        """
        artist = request.db['artists'].find_one(criteria, fields)
        if not artist:
            return False
        self.artist = artist['name']
        song_heap = []
        self.top_songs = song_heap
        if 'songs' in artist:
            for song in artist['songs']:
                count = request.db['concerts'].find(
                    {'setlist_array.song_id': song['song_id']}).count()
                heappush(song_heap, {
                    'title': song['title'],
                    'song_id': song['song_id'],
                    'song_count': count})

        if limit > 0:
            self.top_songs = nlargest(limit,
                                      song_heap,
                                      key=lambda k: k['song_count'])
        else:
            self.top_songs = sorted(song_heap,
                                    key=lambda k: k['song_count'],
                                    reverse=True)
        return True
