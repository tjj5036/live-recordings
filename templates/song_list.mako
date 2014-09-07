<!DOCTYPE html>
<html lang="en">
  <head>
  <title>All Songs for ${artist}</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>

    <%include file="user_header.mako"/>
      <div id="song-list-container" class="container">
          <table id="${artist}_table" class="table table-condensed">
            <thead>
              <tr>
                <td>Top Songs:</td>
                <td></td>
              </tr>
            </thead>
            <tbody id="${artist}_table_content">
              %for song in songs:
                <tr>
                  <td> <a href="${request.route_url('artist_song', artist_id=artist_url, song_title=song['song_id'])}">${song['title']}</a> </td>
                  <td>
                    <div class="progress-bar progress-bar-danger" role="progressbar", aria-valuenow="${song['song_count']}" aria-valuemin="0" aria-valuemax="${max_count}" style="width: ${float(float(song['song_count']) / float(max_count)) * 100}%">
                      <span class="sr-only">${song['song_count']}</span>
                      ${song['song_count']}
                    </div>
                  </td>
                </tr>
               %endfor
            </tbody>
          </table>
      </div>
  </body>
</html>

