<html>
<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Add / Edit Shows</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="admin_header.mako"/>
    <div id="form-container" class="container">
      <div class="row">

        <div class="col-xs-12 ">
          <legend>Concert Information</legend>
        </div>

        <form id='concert_form' action="#">
          <div class="col-xs-6 ">

            Concert ID
            %if action == 'update':
            <label id="ID">${concert['_id']}</label>
            %else:
            <label id="ID">NA</label>
            %endif

            <div class="form-group">
              <label for='concert_id'>Concert Identifier</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="concert_id" placeholder="Concert ID" value="${concert['concert_id'] if concert['concert_id'] else ''}">
              </div>
            </div>

            <div class="form-group">
              <label for='artist'>Artist</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="artist" placeholder="Artist" value="${concert['artist'] if concert['artist'] else ''}">
              </div>
            </div>

            <div id="setlist_options"  class="form-group">
              <label for='setlist'>Setlist Options</label>
                <select class="form-control" id='setlist' multiple='multiple' name='setlist[]' size="10">
                </select>
            </div>  
            
              <label for='old_setlist'>Old Setlist</label>
              <textarea class="form-control" id='old_setlist' rows=10>${old_setlist}</textarea>

            <div class="form-group">
              <label for='date'>Date</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="date" placeholder="Date" 
                value="${concert['date'] if concert['date'] else ''}">
              </div>  
            </div>  

            <div class="form-group">
              <label for='venue'>Venue</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="venue" placeholder="Venue" 
                value="${concert['venue'] if concert['venue'] else ''}">
              </div>  
            </div>  

            <div class="form-group">
              <label for='city'>City</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="city" placeholder="City" value="${concert['city'] if concert['city'] else ''}">
              </div>  
            </div>  

            <div class="form-group">
              <label for='state'>State</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="state" placeholder="State" 
                value="${concert['state'] if concert['state'] else ''}">
              </div>  
            </div>  

            <div class="form-group">
              <label for='country'>Country</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="country" placeholder="Country" 
                value="${concert['country'] if concert['country'] else ''}">
              </div>  
            </div>  

            <div class="form-group">
              <label for='altname'>
                Alternative Name
              </label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="altname" placeholder="Alternative Name" 
                value="${concert['altname'] if concert['altname'] else ''}">
              </div>  
            </div>  

            <div class="form-group">
              <label for='notes'>Notes</label>
              <div class="input-group-sm">
                <textarea class="form-control" rows="5" id="notes" placeholder="Notes">${concert['notes'] if concert['notes'] else ''}</textarea>
              </div>  
            </div>  

            <div class="checkbox">
            <label for='status'>Available for the Masses?</label>
            <input type="checkbox" id="status" checked=${concert['available'] if concert['available'] else '' }> 
            </div>  

          </div>  

          <div class="col-xs-6" id='setlist-container'>
            <div class="form-group">
              <label for='setlist_table'>Setlist</label>
              <table id="setlist_table" class="table">
                <thead>
                  <tr>
                    <th class="position">#</th>
                    <th>ID</th>
                    <th>Name</th>
                  </tr>
                </thead>
                <tbody id="sortable">
                </tbody>
              </table>
            </div>
          </div>

        <div id="submit_div" class="col-xs-12">
          <input type="submit" value="Submit" id="add_button" class="btn">
          <label class="error" for="client_id_manual" id="name_error">
            You need to input an artist!
          </label><br>
        </div>

      </form>
    </div>  
  </div>  

  <%include file="jquery.html"/>
  <script>
  
  /* Hides error labels */
  $('.error').hide();  
  
  /* Performs ajax lookup to get setlists */
  $(document).ready(function(){
    $('#artist').autocomplete({
      source: function( request, response) {
        $.post(
         "${request.route_url('admin_suggest_setlist')}", 
          { artist_name : $("#artist").val() },
          function(response) {
            $('#setlist').empty();
            $('#setlist').append(response.songs);
            return (response);
        });
      }
    });
  });
  
  /* User has already entered an artist (editing the show),
  so automatically suggest a setlist.
  */
  %if concert['artist']:
    get_setlist_options();
  %endif

  /* Suggests a setlist based on what the user
  has entered for the artist.
  */
  function get_setlist_options() {
    $.ajax({
      type:"POST",
      url: "${request.route_url('admin_suggest_setlist')}",
      data:{ 
        artist_name : $("#artist").val()
      },
      success:function(result){
        if (result.action == 'success') {
          $('#setlist').empty();
          $('#setlist').append(result.songs);
          $("#artist").val(result.artist);
          return true;
        }
      }
    });
  }
  
  /* Adds a show to the setlist array */
  $("#setlist").dblclick(function () {
    $("select option:selected").each(function () {
      last = parseInt($("#setlist_table tr:last td:eq(0)").html(), 10);
      if (last) {
        last = last + 1;
      } else {
        last = 1;
      }
      $("#sortable").append(
        '<tr ondblclick="delete_row(this)"><td class="order">' + 
        last + '</td><td>' + $(this).val() + '</td><td>' + 
        $(this).text() + '</td></tr>'
      )
      $("#sortable").sortable("refresh");
    });
  });   
  
  /* Removes a song from the setlist */
  function delete_row(xrow) {
    $(xrow).closest("tr").remove();
    $("#sortable").sortable("refresh");
  }
  
  /* Allows for sorting of setlists */
  $(function() {
    $("#sortable").sortable({
      stop: function(evt, ui) {
        reorder();
      }
    });
  });
  
  /* Used for pre-populating the setlist array.
  Adds all songs that have been added before and
  builds the table with it
  */
  %if concert['setlist_array']:
    $(document).ready(function(){
      %for song in concert['setlist_array']:
        $("#sortable").append(
          '<tr ondblclick="delete_row(this)">' +
          '<td class="order">${song["order"]}</td>' +
          '<td>${song["song_id"]}</td><td>${song["song_name"]} </td></tr>'
        )
      %endfor
      $("#sortable").sortable("refresh");
    });
  %endif
  
  /* When reordering the setlist this ensures that
  the track order number stays intact.
  */
  function reorder() {
    count = parseInt(1, 10);
    $("#sortable tr").each(function(){
      $(this).find("td:first").html(count);
      count = count + 1;
    });
  }

  /* Sends information to the server to be processed and
  added accordingly. This is an ajax call.
  */
  $(document).ready(function(){
    $("#add_button").click(function(){
      event.preventDefault();
      var setlist = new Array( parseInt($("#setlist_table tr:last td:eq(0)").html(), 10));
      count = parseInt(0, 10)
      $("#sortable tr").each(function(){
        var dict = {
          'order' : $(this).find("td:first").html(),
          'song_id' : $(this).find("td:nth-child(2)").html(),
          'song_name' : $(this).find("td:nth-child(3)").html()
        };
        setlist[count] = dict;
        count = count + 1
      });

      if ($("artist").val() == "") {
        $("label#name_error").show();
        $("#name_error").focus();
        return false;
      }
      available = $("#status").is(":checked");

      $.ajax({
        type : "POST",
        url : "${request.route_url('admin_add_show')}",
        data : {
          artist : $("#artist").val(),
          altname : $("#altname").val(),
          city : $("#city").val(),
          country : $("#country").val(),
          date : $("#date").val(),
          notes : $("#notes").val(),
          state : $("#state").val(),
          venue : $("#venue").val(),
          available : available,
          update : $("#ID").html(),
          concert_id : $('#concert_id').val(),
          setlist_array : JSON.stringify(setlist)
        },
        success:function(result){
          $('.error').hide();
          if (result.action == 'success') {
            alert("Show added successfully!");
            return true;
          }
          return false;
        }
      });
    });
  });
</script>
</body>
</html>