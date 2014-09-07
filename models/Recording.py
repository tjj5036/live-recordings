from bson.objectid import ObjectId
import json
import datetime

VIDEO_TYPES = ['AVI', 'MP4', 'DVD', 'MOD', 'MPG',
               'HD', 'FLV', 'VIDEO-OTHER',
               'X264', 'XVID', 'VOB', 'MTS',
               'MKV']
AUDIO_TYPES = ['MP3', 'FLAC', 'SHN', 'OGG']


class Recording_Filter(object):
    """ Filters out what recordings are returned.
    """

    def __init__(self, request, recording_criteria, fields):
        """ Inits the filter
        """
        self.recordings = []
        self.get_recordings(request, recording_criteria, fields)

    def get_recordings(self, request, recording_criteria, fields):
        """ Fetches the recordings that match the criteria """
        recordings = request.db['recordings'].find(
            recording_criteria, fields).sort([('media', 1), ('desc', 1)])
        for recording in recordings:
            self.recordings.append(recording)


class Recording(object):
    """ Class to contain recording information.
    """

    def __init__(self, request, _id):
        """ Inits the recording.
        """
        self._id = _id
        self.concert_ids = []
        self.desc = ''
        self.rtype = ''
        self.source = ''
        self.notes = ''
        self.primary = ''
        self.taper = ''
        self.recording_url_id = ''
        self.files = []
        self.deleted = ''
        self.visible = ''

    def convert_to_concert(self, request, recording):
        """ Populates a recording without making a DB call- whoever
        calls this already has.
        """
        self.get_files(request)
        for key in self.__dict__.viewkeys() & recording.viewkeys():
            self.__dict__[key] = recording[key]

    def populate_recording(self, request):
        """ Populates recording information given an existing concert id
        """
        recording = request.db['recordings'].find_one(
            {'_id': ObjectId(self._id)})
        self.get_files(request)
        for key in self.__dict__.viewkeys() & recording.viewkeys():
            self.__dict__[key] = recording[key]

    def populate_recording_url(self, request):
        """ Populates recording information given an existing concert id
        """
        recording = request.db['recordings'].find_one(
            {'recording_url_id': self.recording_url_id})
        if recording:
            for key in self.__dict__.viewkeys() & recording.viewkeys():
                self.__dict__[key] = recording[key]
            self._id = str(recording['_id'])
            self.get_files(request)
            return True
        return False

    def create_or_edit_recording(self, request, recording):
        """ Creates a recording.
        All attribtues in the check list are considered to be required,
        anything else is optional
        """
        check_list = ['concert_ids', 'desc', 'rtype', 'notes', 'deleted',
                      'source', 'taper',  'primary', 'recording_url_id']
        if all(k in recording for k in check_list):
            existing = request.db['recordings'].find_one(
                {'recording_url_id': recording['recording_url_id']})
            if existing:
                # Would indicate that we are trying to update same document
                if existing['_id'] != ObjectId(recording['id']):
                    return False

            save_dict = {key: recording[key] for key in check_list}
            save_dict['deleted'] = 'False'
            if str(recording['deleted']) == 'true':
                save_dict['deleted'] = 'True'
            save_dict['visible'] = 'False'
            if str(recording['visible']) == 'true':
                save_dict['visible'] = 'True'
            save_dict['date_added'] = datetime.datetime.now()
            save_dict['concert_ids'] = json.loads(recording['concert_ids'])
            save_dict['media'] = 'Audio'
            if save_dict['primary'] in VIDEO_TYPES:
                save_dict['media'] = 'Video'

            # Recording already exists, update it
            if recording['id'] != 'NA':
                request.db['recordings'].update(
                    {'_id': ObjectId(recording['id'])}, save_dict)
            else:
                request.db['recordings'].insert(save_dict)
            return True

        return False

    def get_files(self, request):
        """ Returns all files associated with this particular recording
        TODO: Inline these as opposed to storing them separately
        """
        files = []
        rec_files = request.db['file_locations'].find(
            {'rec_id': self._id})
        for _file in rec_files:
            files.append({
                '_id': _file['_id'],
                'filename': _file['filename'],
                'size': _file['size'],
                'visible': _file['visible'],
                'deleted': _file['deleted']})

        self.files = sorted(files, key=lambda k: k['filename'])
