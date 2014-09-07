<!DOCTYPE html>
<html lang="en">
  <head>
  <title>${artist} - ${song['title']}</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="keywords" content="python web application" />
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="user_header.mako"/>

    <div id="song-info" class="container">
      <div class="row">

        <div id="song-header" class="col-xs-12">
          <h1>${song['title']}</h1>
        </div>
        
        <div class="col-xs-6">
          <div class="row">

            <div id="play-stats">
              <dl class="dl-horizontal">
                %if 'first-played' in song:
                  <dt>First Played:</dt>
                  <dd>${song['first-played'].strftime('%Y/%m/%d')}</dd>
                  <dt>Last Played:</dt>
                  <dd>${song['last-played'].strftime('%Y/%m/%d')}</dd>
                %endif
                <dt>Total Times Played:</dt>
                <dd>${song['count']}</dd>
              </dl>
            </div> <!--play stats -->

            <div id="latest_concerts">
              <table id="latest_concerts_table" class="table table-condensed">
                <thead>
                  <tr>
                    <td rowspan="2">Last Performed At:</td>
                  <tr>
                </thead>
                <tbody id="$latest_concerts_table_content">
                  %for concert in concerts:
                    <tr>
                      <td>${concert['date']}</td>
                      <td><a href="${request.route_url('concert_view', concert_id=concert['concert_id'])}">${concert['venue']}</a></td>
                    </tr>
                   %endfor
                </tbody>
              </table>
            </div>
          </div> 
        </div> <!-- col -->

        <div id="lyrics-text" class="col-xs-6">
          ${song['lyrics'].replace('\n', '<br />') | n} 
        </div> <!--lyrics -->


      </div> <!-- row -->
    </div> <!-- container -->
            

  <%include file="jquery.html"/>
  </body>
</html>
