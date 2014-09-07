<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Add / Edit Songs</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>

    <%include file="admin_header.mako"/>
    <div id="song-list-container" class="container">
      %for artist, song in songs.iteritems():
        <table id="${artist}_table" class="table">
          <thead>
            <tr>
              <td>${artist}</td>
              <td><a href="${request.route_url('admin_edit_song', artist_id=song['id'])}">Add New Song</a></td>  
            </tr>
            <tr>
              <th>Song</th>
              %if permission == 'edit': 
             <th>Edit</th>
              %elif permission =='view':  
             <th>View Lyrics</th>
              %endif
            </tr>
          </thead>
          <tbody id="${artist}_table_content">
             %for s in song['list']:
              <tr>
                <td>${s['song_title']}</td>
                <td><a href="${request.route_url('admin_edit_existing_song', artist_id=s['artist_id'], song_id=s['song_id'])}">Edit</a></td>
              </tr>
             %endfor
          </tbody>
        </table>
      %endfor
    </div>
  </body>
</html>

