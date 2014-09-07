<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Add / Edit Songs</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>

    <%include file="user_header.mako"/>
    <div id="artist_info-container" class="container">
      %for artist, song in songs.iteritems():
        <table id="${artist}_table" class="table">
          <thead>
            <tr>
              <td>Song</td>
            </tr>
            </tr>
          </thead>
          <tbody id="${artist}_table_content">
             %for s in song['list']:
              <tr>
                <td>${s['song_title']}</td>
              </tr>
             %endfor
          </tbody>
        </table>
      %endfor
    </div>
  </body>
</html>


