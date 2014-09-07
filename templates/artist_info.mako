<!DOCTYPE html>
<html lang="en">
  <head>
  <title>${artist}</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>

    <%include file="user_header.mako"/>
    <div id="artist_info-container" class="container">
      <div class="row">

        <div class="col-xs-6" id="latest_concerts">
          <table id="${artist}_latest_concerts_table" class="table table-condensed">
            <thead>
              <tr>
                <td rowspan="2">Latest Concerts:</td>
              <tr>
            </thead>
            <tbody id="${artist}_latest_concerts_table_content">
              %for concert in concerts:
                <tr>
                  <td>${concert['date']}</td>
                  <td><a href="${request.route_url('concert_view', concert_id=concert['concert_id'])}">${concert['venue']}</a></td>
                </tr>
               %endfor
            </tbody>
          </table>
          <a href="${request.route_url('artist_concert_list', artist_id=artist_url)}">All Concerts</a>
        </div> <!-- col -->
          
        <div class="col-xs-6" id="most-played-songs">
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

          <a href="${request.route_url('artist_song_list', artist_id=artist_url)}">All Songs</a>


        </div> <!-- col -->

      </div> <!-- row -->
    </div> <!-- container -->
  </body>
</html>


