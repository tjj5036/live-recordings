<!DOCTYPE html>
<html lang="en">
  <head>
  <title>
  %if recording['desc']:
  ${recording['desc']}
  %else:
  Recording
  %endif  
  </title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="user_header.mako"/>
    <div id="recording-container" class="container">

      <div class="row">
      
        <div class="col-xs-12">
          <legend>Recording Information</legend>
        </div>  

        <div class="col-xs-12">
          <dl class="dl-horizontal">
            <dt>Description</dt>
            <dd>${recording['desc'] if recording['desc'] else ''}</dd>
            %if recording['taper']:
              <dt> Taper: </dt>
              <dd> ${recording['taper']} </dd>
            %endif  
            %if recording['source']:
              <dt> Source: </dt>
              <dd> ${recording['source']} </dd>
            %endif  
            <dt>Recording Type</dt>
            <dd>${recording['rtype'] if recording['rtype'] else ''}</dd>
            %if recording['notes']:
              <dt> Notes: </dt>
              <dd> ${recording['notes']} </dd>
            %endif  
          </dl>
        </div>  

        <div class="col-xs-12">
          <label  for='concert_table'>Associated Concerts:</label>
          <table id="concert_table" class="table table-striped table-hover">
            <thead>
              <tr>
                <th>Artist</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody id="concert_table_values">
              %for artist, concerts in c_list.iteritems():
                %for concert in concerts:
                  <tr class="concert" onclick='window.location.href="${request.route_url("concert_view", concert_id=concert["concert_id"])}"'>
                    <td><a href='${request.route_url("concert_view", concert_id=concert["concert_id"])}'>${concert['artist']}</a></td> 
                    <td>${concert['date']}</td>
                  </tr>
                %endfor
              %endfor
            </tbody>
          </table>
        </div>
        
        %if len(recording['files']) > 0:
          <div class="col-xs-12">
            <label for='file_table'>Available Files:</label>
            <table id="file" class="table">
              <thead>
                <tr>
                  <th>Filename</th>
                  <th>Size</th>
                </tr>
              </thead>
              <tbody id="file_table_values">
                %for file in recording['files']:
                  <tr>
                    <td><a href="${request.route_url('send_file', file_id= file['_id'])}">${file['filename']}</a></td>
                    <td>${file['size']}</td>
                  </tr>  
                %endfor
              </tbody>
            </table>
          </div>
        %endif

      </div> <!-- row -->
    </div>  <!-- container -->
  </body>
</html>
