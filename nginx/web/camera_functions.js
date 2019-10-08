var camera_n = 2;
var display_status = []
for (i = 0; i < camera_n; i++) {
    display_status[i] = false;
}

web_url = ""
api_url = ""

update();
update_fps_status();
update_cam_count();
update_width_text();

setInterval(function(){
    update();
}, 5000);

setInterval(function(){
    set_width();
}, 1000);

function update() {
    document.getElementById("online-status").innerHTML = get_online_status();
    document.getElementById("detection-status").innerHTML = get_detection_status();
}

function update_width_text() {
    t = document.getElementById("width-slider").value;
    document.getElementById("width-status").innerHTML = "Width <b>" + t + "</b>";
    return t
}

function set_width() {
    w = update_width_text();
    cameras = document.getElementsByClassName("camera-view");
    for (i = 0; i < cameras.length; i++) {
        cameras[i].style.width = w + "px";
        cameras[i].style.height = Math.trunc(w*(720/1280)) + "px";
    }
}

function get_online_status() {
    var cameras_online = 0;
    var cameras_offline = 0;

    for (i = 1; i < camera_n+1; i++) {
        //set link to current camera
        link = "http://" + api_url  + "/" + i + "/detection/connection"
        //http request to link
        $.ajax({
            url: link,
            async: false,
            type:'GET',
            success: function(x){
                if (x.includes("Connection OK")) {
                    cameras_online += 1;
                } else {
                    cameras_offline += 1;
                }
            }
        });
    }

    // now camera status is available
    if (cameras_online == camera_n) {
        status = "Status <b>ONLINE</b>";
    } else if (cameras_offline == camera_n) {
        status = "Status <b>OFFLINE</b>";
    } else {
        status = "Status <b>OTHER</b>";
    }
    return status
}

function get_detection_status() {
    var cameras_on = 0;
    var cameras_off = 0;

    for (i = 1; i < camera_n+1; i++) {
        //set link to current camera
        link = "http://" + api_url  + "/" + i + "/detection/status"
        //http request to link
        $.ajax({
            url: link,
            async: false,
            type:'GET',
            success: function(x){
                if (x.includes("Detection status ACTIVE")) {
                    cameras_on += 1;
                } else {
                    cameras_off += 1;
                }
            }
        });
}

    // now camera status is available
    if (cameras_on == camera_n) {
        status = "Detection <b>ON</b>";
    } else if (cameras_off == camera_n) {
        status = "Detection <b>OFF</b>";
    } else {
        status = "Detection <b>OTHER</b>";
    }
    return status;
}

function detection_on() {
    // get current detection status
    status = get_detection_status()
    if (status.includes("ON")) {
        alert("Detection is already on.");
    } else {
        for (var i = 1; i < camera_n+1; i++) {
            //set link to current camera
            link = "http://" + api_url  + "/" + i + "/detection/start";
                //http request to link
                $.ajax({
                    url: link,
                    async: false,
                    type:'GET',
                    success: function(data){
                        console.log("Attempting to start camera " + i);
                    }
                });
            }
        }
}

function detection_off() {
    // forces shutdown of all cameras
    for (var i = 1; i < camera_n+1; i++) {
        //set link to current camera
        link = "http://" + api_url  + "/" + i + "/detection/pause";
            //http request to link
            $.ajax({
                url: link,
                async: false,
                type:'GET',
                success: function(data) {
                    console.log("Attempting to pause camera " + i);
            }
        });
    }
}

function display_cam(n) {
    if (display_status[n] == false) {
        n+=1;
        link = "http://" + web_url  + "/" + n + "/";
        n-=1;
        document.getElementById("cameras").innerHTML += '<a href="' + link + '"><img id="camera' + n + '" class="camera-view" src="' + link + '"></a>';
        display_status[n] = true;
    } else if (display_status[n] == true) {
        document.getElementById("camera" + n).remove();
        display_status[n] = false;
    }
    update_cam_count();
}

function update_cam_count() {
    x = display_status.filter(v => v).length;
    document.getElementById("display-count-status").innerHTML = "Cameras <b>" + x + "</b>";
}

function get_fps() {
    z = [];
    for (var i = 1; i < camera_n+1; i++) {
        //set link to current camera
        link = "http://" + api_url  + "/" + i + "/config/get?query=stream_maxrate"
            //http request to link
            $.ajax({
                url: link,
                async: false,
                type:'GET',
                success: function(data) {
                    z[i-1] = data.split('=')[1].split('Done')[0];
            }
        });
    }
    if (z.every( (val, i, arr) => val === arr[0] )) {
        return z[0]
    } else {
        return -1
    }
}

function update_fps_status() {
    fps = get_fps();
    if (fps == -1) {
        msg = "FPS <b>Error</b>";
    } else {
        msg = "FPS <b>" + fps + "</b>";
    }
    document.getElementById("fps-status").innerHTML = msg
}

function change_fps(fps) {
    for (var i = 1; i < camera_n+1; i++) {
        //set link to current camera
        link = "http://" + api_url  + "/" + i + "/config/set?stream_maxrate=" + fps;
            //http request to link
            $.ajax({
                url: link,
                async: false,
                type:'GET',
                success: function(data) {
                    console.log("Attempting to change fps for camera " + i);
                    update_fps_status();
            }
        });
    }
}
