<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Concerts</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/concert_recording.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>

    <%include file="user_header.mako"/>
    <div id="show-container" class="container">
      
      <div class="row">
        <label class="label label-primary" id='show_filters' onclick="show_filters()">Filter</label>
        <div id="filter" class="row">

          <div id="concert_filter" class="col-xs-12">
            <div class="checkbox">
              <label for="has_files">Has Recordings</label>
              <input id="has_files" type="checkbox">
            </div>  
          </div>  

          <div id="filter_options" class"col-xs-12">

            <div class="col-xs-12">
              <label for"v_types[]">Video Types: </label>
              %for v_type in v_types:
              <input type="checkbox" class="v_types" name="v_types[]" value="${v_type}">${v_type}  
              %endfor
            </div>

            <div class="col-xs-12">
              <label for"a_types[]">Audio Types: </label>
              %for a_type in a_types:
              <input type="checkbox" class="a_types" name="a_types[]" value="${a_type}">${a_type}
              %endfor
            </div>

          </div>

        </div>
      </div>

      <div class="row">
        <div class="col-xs-12">
          %for artist, concert in concert_list.iteritems():
            <table  class="table table-striped table-hover">
              <thead>
                <tr>
                  <th colspan="3">${artist}</th>
                </tr>
                <tr>
                  <th>Date</th>
                  <th>Venue</th>
                  <th>Filetypes</th>
                </tr>
              </thead>
              <tbody >
                %for c in concert:
                  <tr>
                    <td>${c['date']}</td>
                    <td><a href="${request.route_url('concert_view', concert_id=c['concert_id'])}">${c['venue']}</a></td>
                    <td>${c['file_types']}</td>
                  </tr>
                %endfor
              </tbody>
            </table>
          %endfor
        </div>
      </div>
    </div>

  <%include file="jquery.html"/>
  <script>
    
    $('#concert_filter').hide();
    $('#filter_options').hide();

    function update_concerts() {
      var has_recordings = $("#has_files").is(":checked");
      var a_types = new Array();
      var v_types = new Array();
      var artist_id = ($("table:eq(0) tr:eq(0) > th:eq(0)").text());

      $.each($("input[name='a_types[]']:checked"), function() {
        a_types.push($(this).val());
      });
      $.each($("input[name='v_types[]']:checked"), function() {
        v_types.push($(this).val());
      });
      
      a_types = JSON.stringify(a_types);
      v_types = JSON.stringify(v_types);

      $.ajax({
        type:"POST",
        url: "${request.route_url('filter_concert_list')}",
        data:{ 
          a_selected : a_types,
          v_selected : v_types,
          has_recordings : has_recordings,
          artist_id : artist_id,
        },
        success:function(result){
          if (result.action == 'success') {
            var html='';
            $.each(result.concert_list, function(k,v) {
              $.each(v, function(index, value) {
                html += 
                  "<tr>"+ 
                  "<td>"+value.date+"</td>"+ 
                  "<td>"+'<a href="'+value.url+'">'+value.venue+"</a></td>" + 
                  "<td>"+value.file_types+"</td>" +
                  "</tr>";
              });
            });
            $("table:eq(0) tbody").html(html);
          }
          return true;
        }
      });
    }


    /* Redirects user to concert page after they've clicked on a concert
    */
    $('tr').click(function() {
      window.location.href = $(this).find('a').attr('href');
    });
    
    /* Shows the filer options
    */
    function show_filters() {
     $("#concert_filter").toggle();
    }

    /* Filters out concerts that match criteria
    */ 
    $('[name^="v_types[]"]').change(function(event) {
      update_concerts();
      return true;
    });
    $('[name^="a_types[]"]').change(function(event) {
      update_concerts();
      return true;
    });
    $('#has_files').change(function(event) {
      if ( $("#has_files").is(":checked")) {
        $("#filter_options").show();
      } else {
        $("#filter_options").hide();
      }
      update_concerts();
      return true;
    });

  </script>
  </body>
</html>
