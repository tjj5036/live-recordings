from live_rage.models.Recording import Recording
from bson.objectid import ObjectId

import datetime
import json


class List_Filter(object):
    """ Used to filter out concerts that meet a certain criteria.
    """

    def __init__(self, request, criteria, fields, fetch_all, json):
        """ Inits the desired concerts """
        self.concerts = []
        self.concert_map = {}
        if fetch_all:
            self.get_all_files(request)
        self.get_concerts(request, criteria, fields, json)

    def get_concerts(self, request, criteria, fields, json):
        """ Actually gets the concerts """
        concert_list = {}
        concerts = request.db['concerts'].find(
            criteria, fields).sort([('artist', 1), ('date',  1)])

        for concert in concerts:
            if concert['artist'] not in concert_list.keys():
                concert_list[concert['artist']] = []
            if json:
                concert['_id'] = str(concert['_id'])
            concert['url'] = request.route_url(
                'concert_view', concert_id=concert['concert_id'])
            concert_list[concert['artist']].append(concert)
        self.concerts = concert_list

    def get_all_files(self, request):
        """ This is used when generating concert lists.
        It fetches all recordings, and matches them to an
        existing concert object.
        """
        recordings = request.db['recordings'].find(
            {'visible': 'True', 'deleted': 'False'},
            {'primary': 1, 'concert_ids': 1})

        for recording in recordings:
            for concert in recording['concert_ids']:
                if concert not in self.concert_map.keys():
                    self.concert_map[concert] = []
                self.concert_map[concert].append(recording['primary'])

        for concert, recordings in self.concert_map.iteritems():
            file_str = ''
            for file_type in list(set(recordings)):
                file_str += ('%s ' % (file_type,))
            self.concert_map[concert] = file_str

    def get_filtered_recordings(self, request, criteria, has_recordings):
        """ This is used when generating concert lists.
        It filters only recording types that are requested.
        """
        criteria.update({'visible': 'True', 'deleted': 'False'})
        recordings = request.db['recordings'].find(
            criteria, {'primary': 1, 'concert_ids': 1})

        for recording in recordings:
            for concert in recording['concert_ids']:
                if concert not in self.concert_map.keys():
                    self.concert_map[concert] = []
                self.concert_map[concert].append(recording['primary'])

        for concert, recordings in self.concert_map.iteritems():
            file_str = ''
            for file_type in list(set(recordings)):
                file_str += ('%s ' % (file_type,))
            self.concert_map[concert] = file_str

        filtered_list = []
        for artist, concerts in self.concerts.iteritems():
            for concert in concerts:
                concert['file_types'] = ''
            if concert['_id'] in self.concert_map.keys():
                concert['file_types'] = self.concert_map[concert['_id']]
                filtered_list.append(concert)
            else:
                if not has_recordings:
                    filtered_list.append(concert)

        self.concerts[artist] = filtered_list

    def build_file_list(self):
        """ Builds the string containing what recording types
        are available for a given concert
        """
        for artist, concerts in self.concerts.iteritems():
            for concert in concerts:
                concert['file_types'] = ''
                if str(concert['_id']) in self.concert_map.keys():
                    concert['file_types'] = str(
                        self.concert_map[str(concert['_id'])])


class Concert(object):
    """ Contains all information relating to a concert
    """

    def __init__(self, request, _id, restrict):
        """ Initializes the concert. There are different
        levels of information that can be returned.
        """
        self._id = ''
        self.concert_id = _id
        self.artist = ''
        self.country = ''
        self.date = ''
        self.setlist_array = ''
        self.state = ''
        self.available = ''
        self.venue = ''
        self.city = ''
        self.altname = ''
        self.notes = ''
        self.old_setlist = ''

        if _id is not None:
            if (self.populate_information(request)):
                if (restrict == 'INFO_FULL'):
                    self.get_recordings(request)

    def populate_information(self, request):
        """ Gets all information regarding a concert
        """
        concert = request.db['concerts'].find_one(
            {'concert_id': self.concert_id})
        if concert:
            for key in self.__dict__.viewkeys() & concert.viewkeys():
                self.__dict__[key] = concert[key]

            # temporary until all setlists get converted
            if 'setlist' in concert:
                self.old_setlist = concert['setlist']
            else:
                self.old_setlist = ''
            return True
        return False

    def get_recordings(self, request):
        """ Gets all information for each recording  associated with a concert
        """
        recordings = []
        recording_list = request.db['recordings'].find({
            "concert_ids": str(self._id),
            "deleted": "False"})

        for recording in recording_list:
            existing_recording = Recording(request, str(recording['_id']))
            existing_recording.convert_to_concert(request, recording)
            recordings.append(existing_recording.__dict__)
        return recordings

    def update_songs(self, request, artist_name, songs, concert_date):
        """ Updates a song entered into the database.
        """
        artist = request.db['artists'].find_one({'name': artist_name})
        for song in artist['songs']:
            for new_song in songs:
                if new_song['song_id'] == song['song_id']:
                    if 'last-played' not in song.keys():
                        song['last-played'] = concert_date
                    if 'first-played' not in song.keys():
                        song['first-played'] = concert_date
                    if song['last-played'] < concert_date:
                        song['last-played'] = concert_date
                    if song['first-played'] > concert_date:
                        song['first-played'] = concert_date
        request.db['artists'].save(artist)

    def create(self, request, concert):
        """ Creates a new concert
        """
        check_list = [
            'artist', 'setlist_array', 'altname', 'city', 'country', 'date',
            'notes', 'state', 'venue', 'available', 'concert_id']

        if all(k in concert for k in check_list):
            save_dict = {key: concert[key] for key in check_list}
            save_dict['available'] = 'False'
            if str(concert['available']) == 'true':
                save_dict['available'] = 'True'
            save_dict['date_added'] = datetime.datetime.now()
            save_dict['notes'] = concert['notes'].strip()
            save_dict['setlist_array'] = json.loads(concert['setlist_array'])
            self.update_songs(
                request, save_dict['artist'],
                json.loads(concert['setlist_array']),
                datetime.datetime.strptime(save_dict['date'], '%Y-%m-%d'))

            # Concert already exists, update it
            if concert['update'] != 'NA':
                request.db['concerts'].update(
                    {'_id': ObjectId(concert['update'])},
                    {"$set": save_dict}, upsert=False)
            else:
                request.db['concerts'].save(save_dict)
            return True

        return False
