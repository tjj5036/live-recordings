<!DOCTYPE html>
<html lang="en">
  <head>
  <title>${concert['artist']}- ${concert['date']}</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="user_header.mako"/>

    <div id="concert-container" class="container">
    
      <div class="row">

        <div id="artist-header" class="col-xs-12">
          <h1>${concert['artist'] if concert['artist'] else ''}</h1>
        </div>

        <div class="col-xs-6">
          <dl class="dl-horizontal">
            <dt>Date:</dt>
            <dd>${concert['date'] if concert['date'] else ''} </dd>
            <dt>Venue:</dt>
            <dd>${concert['venue'] if concert['venue'] else ''} </dd>
            <dt>Location:</dt>
            <dd>
            ${concert['city'] if concert['city'] else ''} ${concert['state'] if concert['state'] else ''}, 
            ${concert['country'] if concert['country'] else ''}
            </dd>
            %if concert['altname']:
              <dt>Alternative Name:</dt>
              <dd>${concert['altname']}</dd>
            %endif  
            %if concert['notes']:
              <dt>Notes:<dt>
              <dd>${concert['notes']}</dd>
            %endif  
          </dl>
        </div> <!-- Basic Information -->

        <div class="col-xs-6">
          <div id="setlist-container" class="col-xs-6">
            %for song in concert['setlist_array']:
              ${song['order']}. <a href="${request.route_url('artist_song', artist_id=artist_id, song_title=song['song_id'])}">${song['song_name']}</a></br>
            %endfor
          </div>
        </div> <!-- setlist information -->

      </div> <!--row -->

    <% count = 0 %>
    <div id="recording-container">
      <div class="row">

        %if len(recordings) > 0:
        <div id="recording_header">
          <h3>Recordings:</h3>
        </div>
        %endif

        %for recording in recordings:
          <div class="col-xs-12">
            <dl class="dl-horizontal">
              %if recording['taper']:
                <dt>Taper:</dt>
                <dd>${recording['taper']}</dd>
              %endif
              %if recording['source']:
                <dt>Source:</dt>
                <dd>${recording['source']}</dd>
              %endif
              %if recording['rtype']:
                <dt>Recording Type:</dt>
                <dd>${recording['rtype']}</dd>
              %endif
              %if recording['notes']:
                <dt>Notes:</dt>
                <dd>${recording['notes']}</dd>
              %endif
              %if len(recording['files']) > 0:
                <dt>
                <label class="label label-primary"id='associated_files' onclick="$('#' + 'table_${count}').toggle();">Available Files:</label>
                </dt>
              %endif
            </dl> 
          </div>  <!-- Individual recording information -->


          %if len(recording['files']) > 0:
            <div class="col-xs-12">
              <div id='table_${count}'>
                <table class="table">
                  <thead>
                    <tr>
                      <th>Filename</th>
                      <th>Size</th>
                    </tr>
                  </thead>
                  <tbody>
                    %for file in recording['files']:
                      <tr>
                        <td>
                          <a href="${request.route_url('send_file', file_id= file['_id'])}">${file['filename']}</a>
                        </td>
                        <td>${file['size']}</td>
                      </tr>  
                    %endfor
                  </tbody>
                </table>
              </div> <!-- table_count -->
            </div> <!-- col-12 -->
          %endif

          <% count = count + 1 %>

        %endfor

      </div> <!--row -->
    </div> <!-- recording-container-->
  </div> <!-- container -->

  <%include file="jquery.html"/>
  <script>
    $(document).ready(function(){
      $('div[id^="table_"]').hide();
    });
  </script>
  </body>
</html>