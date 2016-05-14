$("#toggl_start_button").click(function(){
    $("#toggl_details").html("<div class='alert alert-info' role='alert'> <p>Starting Timer...</p> </div>");
    $("#toggl_start_button").hide()
});
$("#toggl_restart_button").click(function(){
    $("#toggl_details").html("<div class='alert alert-info' role='alert'> <p>Starting Timer...</p> </div>");
    $("#toggl_start_button").hide()
});

function show_resolutions() {
    var status = $( "#status_select" ).val();
    var transitions = $.parseJSON($( "#transitions").val());
    if (status == '') {
        $("#resolution_select").hide();
        $("#resolution_select").prop('selectedIndex', 0);
    } else {
        $.each(transitions, function( index, value ) {
            if(value.id == status) {
                if (value.type == "Complete") {
                    $("#resolution_select").show();
                } else {
                    $("#resolution_select").hide();
                    $("#resolution_select").prop('selectedIndex', 0);
                }
            }
        });
    }
}

function replace_submit_button() {
  $(".modal-footer").html("<div class='alert alert-info' role='alert'> <p>Submitting...</p> </div>");
}