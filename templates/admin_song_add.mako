<!DOCTYPE html>
<html lang="en">
  <head>
  <title>Add / Edit Song</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="keywords" content="python web application" />
  <meta name="description" content="Management" />
  <link href="${request.static_url('live_rage:static/bootstrap.css')}" rel="stylesheet">
  <link href="${request.static_url('live_rage:static/admin.css')}" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%include file="admin_header.mako"/>

    <div id="edit-song" class="container">
      <div class="row">
        <form id='add_song' role="form" action="">
            
          <div class="col-xs-6">
            <div class="form-group">
              <label for='artist_id'>Artist ID:</label>
              <p id="artist_id" class="form-control-static">${artist_id}</p>
            </div>
          </div>

          <div class="col-xs-6">
            <div class="form-group">
              <label for='song_id'>Song ID:</label>
              %if action == 'update':
              <p id="song_id" class="form-control-static">${song['song_id']}</p>
              %else:
              <p id="song_id" class="form-control-static">NA</p>
              %endif
            </div>
          </div>
        </div> <!--row -->
        
        %if 'first-played' in song:
          <div class="row">
            <div class="col-xs-6">
              <div class="form-group">
                <label for="first-played">First Played:</label>
                <p id="last-played" class="form-control-static">${song['first-played'].strftime('%Y/%m/%d')}</p>
              </div>
            </div>

            <div class="col-xs-6">
              <div class="form-group">
                <label for="last-played">Last Played:</label>
                <p id="last-played" class="form-control-static">${song['last-played'].strftime('%Y/%m/%d')}</p>
              </div>
            </div>
          </div> <!--row -->
        %endif
        
        <div class="row">
          <div class="col-xs-12">

            <div class="form-group">
              <label for='title'>Title</label>
              <div class="input-group-sm">
                <input class="form-control" type="text" id="title" placeholder="Title" value="${song['title'] if song['title'] else ''}">
              </div>  
            </div>  

            <label for='lyrics'>Lyrics</label>
            <textarea class="form-control" rows="20" id="lyrics" placeholder="Lyrics">${song['lyrics'] if song['lyrics'] else ''}</textarea>
        
            <button type="submit" id="add_button" class="btn btn-default">Submit</button>
            <button type="submit" id="delete_button" class="btn btn-default">Delete</button>
            <label class="error" for="client_id_manual" id="name_error">You need to input a name!</label><br>

          </form>
        </div>  <!-- col-12 -->
      </div> <!-- row --> 
    </div> <!-- container --> 

    <%include file="jquery.html"/>
    <script>
      $('.error').hide();  

      $(document).ready(function(){

        /* Adds or updates a song to the database */
        $("#add_button").click(function(){
          event.preventDefault();
          if (title == "") {
            $("label#name_error").show();
            $("#name_error").focus();
            return false;
          }
          $.ajax({
            type:"POST",
            url: "${request.route_url('admin_add_song')}",
            data:{ 
              artist_id : $("#artist_id").text(),
              title : $("#title").val(),
              lyrics : $("#lyrics").val(),
              update : $("#song_id").text()
            },
            success:function(result){
              $('.error').hide();  
              if (result.action == 'success') {
                alert("Song added successfully!");
                $('#title').val('');
                $('#lyrics').val('');
                $("#artist").text('NA');
                return true;
              }
              console.log("Unsuccessful");
            }
          });
        });

        /* Deletes a song from the database */
        $("#delete_button").click(function(){
          event.preventDefault();
          if ($("#ID").html() == 'NA') {
            alert("You cannot delete an empty song dumbass!");
            return false;
          }
          $.ajax({
            type:"POST",
            url: "${request.route_url('admin_delete_song')}",
            data:{ 
              artist_id : $("#artist_id").text(),
              song_id : $("#song_id").text(),
            },
            success:function(result){
              if (result.action == 'success') {
                alert("Song deleted successfully!");
                window.location.replace("${request.route_url('admin_song_list')}");
              }
              console.log("Unsuccessful");
            }
          });
        });
      });

  </script>
  </body>
</html>
