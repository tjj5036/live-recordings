def includeme(config):    

    #  Admin Routes
    config.add_route('login', '/login')
    config.add_route('logout', '/logout')

    config.add_route('admin_main', '/admin')
    config.add_route('admin_suggest_setlist', '/admin/setlist/suggest')

    config.add_route('admin_list_show', '/admin/shows')
    config.add_route('admin_add_show', '/admin/shows/add')
    config.add_route('admin_add_new_show', '/admin/shows/edit')
    config.add_route('admin_edit_existing_show',
                     '/admin/shows/edit/{concert_id}')

    config.add_route('admin_add_user', '/admin/users/add')
    config.add_route('admin_edit_user', '/admin/users/edit')

    config.add_route('admin_song_list', '/admin/songs')
    config.add_route('admin_add_song', '/admin/songs/add')
    config.add_route('admin_delete_song', '/admin/songs/delete')
    config.add_route('admin_edit_song', '/admin/songs/edit/{artist_id}')
    config.add_route('admin_edit_existing_song',
                     '/admin/songs/edit/{artist_id}/{song_id}')

    config.add_route('admin_list_recording', '/admin/recordings')
    config.add_route('admin_add_recording', '/admin/recordings/add')
    config.add_route('admin_edit_recording', '/admin/recordings/edit')
    config.add_route('admin_delete_recording', '/admin/recordings/delete')
    config.add_route('admin_edit_existing_recording',
                     '/admin/recordings/edit/{recording_id}')

    config.add_route('admin_set_file_visibility', '/admin/file/visible')
    config.add_route('admin_delete_file', '/admin/file/delete')
    config.add_route('admin_upload_file', '/admin/file/upload')

    # User Routes
    config.add_route('concert_list', 'concerts/')
    config.add_route('concert_view', '/concert/{concert_id}')
    config.add_route('filter_concert_list', '/concerts/filtered')

    config.add_route('recording_list', '/recordings')
    config.add_route('render_recording', '/recordings/{recording_id}')
    config.add_route('get_filtered_recordings',
                     '/recordings/{recording_criteria}')

    config.add_route('artist_list', '/artists')
    config.add_route('artist_info', '/artists/{artist_id}/')
    config.add_route('artist_concert_list', '/artists/{artist_id}/concerts/')
    config.add_route('artist_song_list', '/artists/{artist_id}/songs/')
    config.add_route('artist_song', '/artists/{artist_id}/songs/{song_title}')

    config.add_route('main', '/')
    config.add_route('about', '/about')
    config.add_route('send_file', '/file/{file_id}')
    config.add_static_view('static', 'live_rage:static')
    
    config.scan('.')
