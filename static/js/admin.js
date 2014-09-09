(function( live_recordings, $, undefined) {
    /* When reordering the setlist this ensures that
    the track order number stays intact.
    */
    function reorder() {
        count = parseInt(1, 10);
        $("#sortable tr").each(function(){
            $(this).find("td:first").html(count);
            count = count + 1;
        });
    };

    function delete_row(xrow) {
        $(xrow).closest("tr").remove();
        $("#sortable").sortable("refresh");
    };

    function getSetlistOptions() {
        $.ajax({
            type: 'POST',
            url: "/admin/setlist/suggest",
            data: { 
                artist_name : $("#artist").val()
            },
            success:function(result){
                if (result.action == 'success') {
                    $('#setlist').empty();
                    $('#setlist').append(result.songs);
                    $("#artist").val(result.artist);
                    return true;
                }
            },
            error:function(e) {
                console.log('error' + e);
            }
        });
    };

    $('#artist').on('keyup', function() {
        getSetlistOptions();
    });
    
    live_recordings.fetchSetlists = function() {
        $('#artist').autocomplete({
            source: function(request, response) {
                $.post(
                    "{{request.route_url('admin_suggest_setlist')}}",
                    {artist_name : $("#artist").val()},
                    function(response) {
                        $('#setlist').empty();
                        $('#setlist').append(response.songs);
                        return (response);
                    }
                );
            }
        });
    };

    /* Adds a show to the setlist array */
    $("#setlist").on('dblclick', function () {
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
                $(this).text() + '</td></tr>');
            $("#sortable").sortable("refresh");
        });
    });

    live_recordings.EnableSetlistSortable = function() {
        /* Allows for sorting of setlists */
        $(function() {
            $("#sortable").sortable({
                stop: function(evt, ui) {
                    reorder();
                }
            });
        });
    };
    
    live_recordings.addConcert = function() {
        $("#add_button").on('click', function(e) {
            e.preventDefault();
            var setlist = new Array(parseInt($("#setlist_table tr:last td:eq(0)").html(), 10));
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
                type: "POST",
                url: "{{request.route_url('admin_add_show')}}",
                data: {
                    artist: $("#artist").val(),
                    altname: $("#altname").val(),
                    city: $("#city").val(),
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
    };

} (window.live_recordings = window.live_recordings || {}, jQuery ));

