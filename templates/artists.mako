<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Artists</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Artists" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="user_header.mako"/>
    <div id="artist-container" class="container">
      <div="row">
      
        <table id="artist_table" class="table">
          <thead>
            <tr>
              <td>Artist</td>
              <td>Number of Shows</td>
            </tr>
          </thead>
          <tbody>
            %for artist_url, artist_info in sorted(artists.iteritems()):
              <tr>
                <td>${artist_info['name']}</td>
                <td><a href="${request.route_url('artist_info', artist_id=artist_url)}">${artist_info['show_count']}</a></td>  
              </tr>
            %endfor
          </tbody>
        </table>

      </div> <!-- row -->
    </div> <!-- container -->
    <%include file="jquery.html"/>
  </body>
</html>
