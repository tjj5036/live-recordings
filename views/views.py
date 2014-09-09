from pyramid.httpexceptions import (HTTPFound,
                                    HTTPNotFound,
                                    HTTPForbidden)
from pyramid.view import (view_config,
                          forbidden_view_config)

from pyramid.security import (authenticated_userid,
                              forget,
                              remember)

from pyramid.response import FileResponse
from bson.objectid import ObjectId
from live_rage.models.User import User
from live_rage.models.Concert import Concert, List_Filter
from live_rage.models.Artist import Artist, Artist_Filter
from live_rage.models.Recording import (Recording,
                                        Recording_Filter,
                                        AUDIO_TYPES,
                                        VIDEO_TYPES)
import json
import logging
import markdown

log = logging.getLogger(__name__)


@forbidden_view_config()
def forbidden_view(request):
    """ Handles 403 instances
    """
    if authenticated_userid(request):
        return HTTPForbidden()
    loc = request.route_url('login', _query=(('next', request.path),))
    return HTTPFound(location=loc)


@view_config(context=HTTPNotFound, renderer="404.jinja2")
def not_found(self, request):
    """ Handles all 404 instances
    """
    return dict()


@view_config(route_name='login', renderer='login.jinja2')
def login_view(request):
    """ Logs a user in, redirect them to admin main.
    """
    next = request.params.get('next') or request.route_url('admin_main')
    message = ''
    if 'form.submit' in request.params:
        login = request.params['login']
        password = request.params['password']
        New_User = User(login, password, None)
        if New_User.authenticate(request):
            headers = remember(request, login)
            log.info("[event=login][auth=succeeded][username=%s]", login)
            return HTTPFound(location=next, headers=headers)
        log.info("[event=login][auth=failed][username=%s]", login)
        message = 'Failed login'
    return dict(message=message, next=next)


@view_config(route_name='logout')
def logout_view(request):
    """ Logs a user out """
    headers = forget(request)
    loc = request.route_url('login')
    return HTTPFound(location=loc, headers=headers)


@view_config(route_name='artist_concert_list',
             renderer='basic/concert_list.jinja2')
def artist_concert_list(request):
    """ Gets all concerts associated with a given artist.
    """
    artist_normalized = request.db['artists'].find_one(
        {'url-name': request.matchdict['artist_id']},
        {'name': 1})
    log.info("[event=get_artist_concerts][artist=%s]",
             request.matchdict['artist_id'])

    concert_list = List_Filter(
        request,
        {'available': 'True', 'artist': artist_normalized['name']},
        {'artist': 1, 'date': 1, 'venue': 1, '_id': 1, 'concert_id': 1},
        True, False)

    concert_list.build_file_list()
    return dict(
        concert_list=concert_list.concerts,
        v_types=VIDEO_TYPES,
        a_types=AUDIO_TYPES)


@view_config(route_name='concert_list', 
             renderer='basic/concert_list.jinja2')
def concert_list(request):
    """ Displays all available concerts to the user.
    """
    concert_list = List_Filter(
        request,
        {'available': 'True'},
        {'artist': 1, 'date': 1, 'venue': 1, '_id': 1, 'concert_id': 1},
        True, False)

    log.info("[event=get_artist_concerts][artist=all]")
    concert_list.build_file_list()
    return dict(
        concert_list=concert_list.concerts,
        v_types=VIDEO_TYPES,
        a_types=AUDIO_TYPES)


@view_config(route_name='filter_concert_list', renderer='json')
def filter_concert_list(request):
    """ Filters the concerts returned based on user selection
    """
    if request.method == 'POST':
        media_types = []
        if 'a_selected' in request.POST:
            media_types.extend(json.loads(request.POST['a_selected']))
        if 'v_selected' in request.POST:
            media_types.extend(json.loads(request.POST['v_selected']))

        has_recordings = False
        if request.POST['has_recordings'] == 'true':
            has_recordings = True

        concert_list = List_Filter(
            request,
            {'available': 'True', 'artist': request.POST['artist_id']},
            {'artist': 1, 'date': 1, 'venue': 1, '_id': 1, 'concert_id': 1},
            False, True)

        criteria = {}
        if has_recordings and len(media_types) > 0:
            criteria['primary'] = {'$in': media_types}

        concert_list.get_filtered_recordings(request, criteria, has_recordings)
        return {
            'concert_list': concert_list.concerts,
            'action': 'success'}


@view_config(route_name='concert_view',
             renderer='basic/concert_view.jinja2')
def concert_view(request):
    """ This fetches the appropriate information associated with
    a single concert and displays it to the user.
    This will get all recordings and associated files as well.
    """
    concert_id = request.matchdict['concert_id']
    concert = Concert(request, concert_id, "INFO_FULL")
    if concert._id == '':
        raise HTTPNotFound

    artist_id = request.db['artists'].find_one(
        {'name': concert.artist},
        {'url-name': 1})
    artist_id = artist_id['url-name']

    return dict(
        concert=concert.__dict__,
        artist_id=artist_id,
        recordings=concert.get_recordings(request))


@view_config(route_name='about', renderer='basic/about.jinja2')
def about(request):
    """ Simply returns the about page
    """
    return dict(
        contact_email=str(request.registry.settings['contact_email'])
    )


@view_config(route_name='recording_list',
             renderer='basic/recording_list.jinja2')
def recording_list(request):
    """ Gets a list of recordings that are visible.
    """
    log.info("[event=recording_list][display=all]")
    fields = {'desc': 1, 'primary': 1, 'recording_url_id': 1}
    recording_criteria = {'visible': 'True', 'deleted': 'False'}
    return dict(
        recording_list=Recording_Filter(
            request, recording_criteria, fields).recordings)


@view_config(route_name='get_filtered_recordings')
def get_filtered_recordings(request):
    pass


@view_config(route_name='render_recording',
             renderer='basic/recording_view.jinja2')
def render_recording(request):
    """ Displays information for an available recording.
    """

    if 'recording_id' in request.matchdict:
        recording = Recording(request, request.matchdict['recording_id'])
        recording.recording_url_id = recording._id

        if not recording.populate_recording_url(request):
            raise HTTPNotFound

        new_ids = []
        for _id in recording.concert_ids:
            new_ids.append(ObjectId(_id))

        list_criteria = {'_id': {'$in': new_ids}}
        fields = {'artist': 1, 'date': 1, 'concert_id': 1}
        List = List_Filter(request, list_criteria, fields, False, False)

        return dict(
            recording=recording.__dict__,
            c_list=List.concerts)


@view_config(route_name="send_file")
def send_file(request):
    if 'file_id' in request.matchdict:
        file_id = request.matchdict['file_id']
        log.info('[event=send_file][file_id=%s', file_id)
        _file = request.db['file_locations'].find_one(
            {'_id': ObjectId(file_id)})

        if _file['deleted'] == 'False' and _file['visible'] == 'True':
            response = FileResponse(_file['location'], request=request)
            response.content_disposition = (
                'attachment; filename="%s"' % (_file['filename']))
            request.db['file_locations'].update(
                {'_id': ObjectId(request.matchdict['file_id'])},
                {'$inc': {'downloads': 1}})
            return response

    raise HTTPNotFound


@view_config(route_name="artist_song", renderer="basic/song.jinja2")
def artist_song(request):
    """ Displays a song associated with an artist
    """
    artist_id = request.matchdict['artist_id']
    song_title = request.matchdict['song_title']
    artist = Artist('', '', request)
    artist.get_song_url(request, artist_id, song_title, 10)

    if artist.song['song_id'] == '':
        raise HTTPNotFound
    
    artist.song['lyrics'] = markdown.markdown(artist.song['lyrics'], extensions=['nl2br'])
    return dict(
        artist=artist.artist,
        song=artist.song,
        concerts=artist.song_at_concerts)


@view_config(route_name="artist_song_list", renderer="basic/song_list.jinja2")
def artist_song_list(request):
    """ Displays ALL Songs associated with a count.
    """
    artist_id = request.matchdict['artist_id']
    artist = Artist('', '', request)
    if not artist.get_artist_limit_songs(
            request, {'url-name': artist_id},
            {'name': 1, 'url-name': 1, 'songs': 1}, 0):
        raise HTTPNotFound

    max_count = 100
    if len(artist.top_songs) > 0:
        max_count = artist.top_songs[0]['song_count']

    return dict(
        artist=artist.artist,
        artist_url=artist_id,
        songs=artist.top_songs,
        max_count=max_count)


@view_config(route_name="artist_info", renderer="basic/artist_info.jinja2")
def artist_info(request):
    """ Displays information associated with an artist.
    """
    artist_id = request.matchdict['artist_id']
    artist = Artist('', '', request)
    if not artist.get_artist_limit_songs(
            request, {'url-name': artist_id},
            {'name': 1, 'url-name': 1, 'songs': 1}, 10):
        raise HTTPNotFound

    artist.get_latest_concerts(
        {'artist': artist.artist},
        {'date': 1, 'venue': 1, 'concert_id': 1},
        10, request)

    max_count = 100
    if len(artist.top_songs) > 0:
        max_count = artist.top_songs[0]['song_count']
        if max_count == 0:
            max_count = 100

    return dict(
        artist=artist.artist,
        artist_url=artist_id,
        songs=artist.top_songs,
        concerts=artist.latest_concerts,
        max_count=max_count)


@view_config(route_name="main", renderer="basic/artists.jinja2")
@view_config(route_name="artist_list", renderer="basic/artists.jinja2")
def view_artists(request):
    """ Displays all artists.
    """
    log.info("[event=main][artist_display=all]")
    artists = Artist_Filter()
    artists.get_artists_only(request, {'name': 1, 'url-name': 1})
    return dict(artists=artists.artists)
