<html>
  <head>
  <title>Recordings</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="user_header.mako"/>
    
    <div id="filter-container" class="container">
      
      
    </div>

    <div id="show-container" class="container">
      <table id="recording_table" class="table">

        <thead>
          <tr>
            <th>Description</th>
            <th>Primary Media Type</th>
          </tr>
        </thead>

        <tbody id="$recording_table_content">
          %for recording in recording_list:
            <tr>
              <td><a href="${request.route_url('render_recording', recording_id=recording['recording_url_id'])}">${recording['desc']}</a></td>
              <td>${recording['primary']}</td>
            </tr>
          %endfor
        </tbody>
      </table>
    </div>

  <%include file="jquery.html"/>
  <script>

    /* Redirects to recording when row is clicked
    */
    $(document).ready(function(){
      $('tr').click(function() {
        window.location.href = $(this).find('a').attr('href');
      });

      /* Filters out recordings based on media type
      */
    });
  </script>
  </body>
</html>
