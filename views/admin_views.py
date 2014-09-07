from pyramid.view import view_config
from pyramid.security import (Allow,
                              ALL_PERMISSIONS,
                              authenticated_userid)
from live_rage.models.User import User
from live_rage.models.Concert import Concert, List_Filter
from live_rage.models.Artist import Artist, Artist_Filter
from live_rage.models.Recording import Recording, Recording_Filter
from live_rage.models.File import FileUpload
from bson.objectid import ObjectId


class Root(object):
    """ Maps groups to permissions
    """
    __acl__ = [
        (Allow, 'g:setlist', 'setlist'),
        (Allow, 'g:admin', ALL_PERMISSIONS)]

    def __init__(self, request):
        """ Inits the group->permissions object
        """
        pass


@view_config(route_name='admin_main', renderer='admin_main.mako',
             permission='setlist')
def admin_main(request):
    """ Administrator's home page
    """
    return dict()


@view_config(route_name='admin_add_user', renderer='json')
@view_config(route_name='admin_edit_user', renderer='admin_user_add_edit.mako',
             permission='admin')
def admin_user_add(request):
    if request.method == 'POST':
        if not all(k in request.POST for k in
                   ('username', 'password', 'permissions[]')):
            return {'action': 'error'}

        NewUser = User(
            request.POST['username'],
            request.POST['password'],
            request.POST['permissions[]'])
        NewUser.create_or_update(request)
        return {'action': 'success'}

    return dict(logged_in=authenticated_userid(request))


@view_config(route_name='admin_suggest_setlist', renderer='json')
def admin_suggest_setlist(request):
    """ Setlists suggestion.
    """
    if request.method == 'POST':
        if 'artist_name' not in request.POST.keys():
            return {'action': 'error'}
        artist = request.POST['artist_name']
        Song_Finder = Artist(artist, 'AUTOCOMPLETE', request)
        return {
            'action': 'success',
            'artist': Song_Finder.artist,
            'songs': Song_Finder.songs}


@view_config(route_name='admin_add_show', renderer='json')
@view_config(route_name='admin_add_new_show',
             renderer='admin_show_add_edit.mako',
             permission='setlist')
@view_config(route_name='admin_edit_existing_show',
             renderer='admin_show_add_edit.mako',
             permission='setlist')
def admin_show_add(request):
    """ Adds or edits a show.
    """
    if request.method == 'POST':
        concert = Concert(request, None, '')
        if concert.create(request, request.POST):
            return {'action': 'success'}
        return {'action': 'failure'}

    if 'concert_id' in request.matchdict:
        concert_id = request.matchdict['concert_id']
        concert = Concert(request, concert_id, "INFO_SINGLE")
        action = 'update'
    else:
        concert = Concert(request, None, '')
        action = 'insert'

    return dict(
        concert=concert.__dict__,
        old_setlist=concert.old_setlist,
        logged_in=authenticated_userid(request),
        action=action)


@view_config(route_name='admin_song_list', renderer='admin_song_list.mako',
             permission='setlist')
def admin_song_list(request):
    """ Returns all songs that correspond to a given artist
    """
    artist = Artist_Filter()
    artist.get_songs(request, {}, {'name': 1, 'songs': 1})
    return dict(
        songs=artist.songs,
        permission='edit',
        logged_in=authenticated_userid(request))


@view_config(route_name='admin_delete_song', renderer='json')
def admin_delete_song(request):
    """ Deletes an existing song.
    """

    if request.method == 'POST':
        if all(k in request.POST for k in ('artist_id', 'song_id')):
            artist = Artist('', '', request)
            artist.delete_song(request, request.POST)
            return {'action': 'success'}
        return {'action': 'error'}


@view_config(route_name='admin_edit_song',
             renderer='admin_song_add.mako',
             permission='setlist')
@view_config(route_name='admin_edit_existing_song',
             renderer='admin_song_add.mako',
             permission='setlist')
@view_config(route_name='admin_add_song', renderer='json')
def admin_add_edit_song(request):
    """ Adds or edits a song
    """

    if request.method == 'POST':
        if all(k in request.POST for k in (
                'artist_id', 'title', 'lyrics', 'update')):
            artist = Artist('', "ADDSONG", request)
            artist.add_or_edit_song(request, request.POST)
            return {'action': 'success'}
        return {'action': 'error'}

    artist_id = request.matchdict['artist_id']
    if 'song_id' in request.matchdict:
        song_id = request.matchdict['song_id']
        song = Artist(artist_id, "d", request)
        song.get_song(request, artist_id, song_id)
        action = 'update'
    else:
        song = Artist(artist_id, "d", request)
        action = 'insert'

    return dict(
        artist_id=artist_id,
        action=action,
        song=song.song,
        logged_in=authenticated_userid(request))


@view_config(route_name='admin_edit_recording',
             renderer='admin_recording_add_edit.mako',
             permission='admin')
@view_config(route_name='admin_edit_existing_recording',
             renderer='admin_recording_add_edit.mako',
             permission='admin')
@view_config(route_name='admin_add_recording', renderer='json')
def admin_add_edit_recording(request):
    """ Adds or edits a recording """
    recording = Recording(request, '')

    # Updates
    if request.method == 'POST':
        if (recording.create_or_edit_recording(request, request.POST)):
            return {"action": "success", '_id': str(recording._id)}
        else:
            return {"action": "error", '_id': str(recording._id)}

    # Existing recording
    action = 'insert'
    if 'recording_id' in request.matchdict:
        recording.recording_url_id = request.matchdict['recording_id']
        recording.populate_recording_url(request)
        action = 'update'

    fields = {'artist': 1, 'date': 1}
    List = List_Filter(request, {},  fields, False, False)
    return dict(
        recording=recording.__dict__,
        action=action,
        c_list=List.concerts,
        logged_in=authenticated_userid(request))


@view_config(route_name='admin_delete_file', renderer='json')
def admin_delete_file(request):
    """ Deletes a file from the database.
    """
    if request.method == 'POST':
        deleted = 'False'
        if request.POST['deleted'] == 'true':
            deleted = 'True'

        request.db['file_locations'].update(
            {'_id': ObjectId(request.POST['_id'])},
            {'$set': {'deleted': deleted}})
    return {'action': 'success'}


@view_config(route_name='admin_set_file_visibility', renderer='json')
def admin_set_file_visibility(request):
    """ Sets the visibility of a file from admin form
    """
    if request.method == 'POST':
        visible = 'False'
        if request.POST['visible'] == 'true':
            visible = 'True'

        request.db['file_locations'].update(
            {'_id': ObjectId(request.POST['_id'])},
            {'$set': {'visible': visible}})

    return {'action': 'success'}


@view_config(route_name="admin_upload_file", renderer='json',
             permission='admin')
def admin_upload_file(request):
    """ Uploads a file (only handles one at a time at the moment).
    """
    recording_id = ''
    for k, v in request.POST.iteritems():
        if k == "recording_id":
            recording_id = v
            break

    for k, v in request.POST.iteritems():
        if k == "files[]":
            _file = FileUpload(recording_id, v, request)
            break

    return {
        "_id": _file._id,
        "filename": _file.filename,
        "valid": _file.valid,
        "visible": _file.visible,
        "deleted": _file.deleted,
        'message': _file.message,
        "size": _file.size,
        'url': request.route_url('send_file', file_id=_file._id)}


@view_config(route_name='admin_delete_recording', renderer='json')
def admin_delete_recording(request):
    """ Deletes the recording (ie, sets a "delete" flag on it).
    """
    if request.method == 'POST':
        request.db['recordings'].update(
            {'_id': ObjectId(request.POST['_id'])},
            {'$set': {'deleted': 'True'}})

    return {'action': 'success'}


@view_config(route_name='admin_list_show', renderer='admin_show_list.mako',
             permission="setlist")
def admin_show_list(request):
    """ Gets a list of all (including deleted) shows.
    """
    fields = {'artist': 1, 'date': 1, 'venue': 1, 'concert_id': 1}
    List = List_Filter(request, {}, fields, False, False)
    return dict(
        concert_list=List.concerts,
        permission='edit',
        logged_in=authenticated_userid(request))


@view_config(route_name='admin_list_recording',
             renderer='admin_recording_list.mako',
             permission='setlist')
def admin_recording_list(request):
    """ Gets a list of all (including deleted) recordings.
    """
    fields = {'desc': 1, 'primary': 1, 'deleted': 1, 'recording_url_id': 1}
    return dict(
        recording_list=Recording_Filter(request, {}, fields).recordings,
        permission='edit',
        logged_in=authenticated_userid(request))
