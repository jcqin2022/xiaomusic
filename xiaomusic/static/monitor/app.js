$(function(){
  // global variable
  var g_did = "";
  var g_songs = {};
  // end

  // == websocket io
  socket = io({
    path: '/ws',
  });
  socket.connect();
  socket.on('connect', function() {
      console.log('Connected to WebSocket server');
  });

  socket.on('disconnect', function() {
      console.log('Disconnected from WebSocket server');
  });

  // socket.on('response', function(data) {
  //     $('#messages').append('<p>' + data.data + '</p>');
  // });

  socket.on('playing', function(data) {
    console.log('playing:' +  data.song);
    get_playing_music(g_did);
    $("#status").text("播放中");
  });

  socket.on('status', function(data) {
    console.log('status:' +  data);
    $("#status").text(data);
  });

  socket.on('downloading', function(data) {
    addDataToList("下载", data);
  });
  // end websocket io

  // == bind controls
  $("#refreshButton").on("click", () => {
    build_music_list();
  });

  $("#play").on("click", () => {
    var search_key = $("#music-name").val();
    var filename=$("#music-filename").val();
    let cmd = "播放歌曲"+search_key+"|"+filename;
    sendcmd(cmd);
  });
  $("#download").on("click", () => {
    var search_key = $("#music-name").val();
    var name=$("#music-filename").val();
    $.post(`/downloadmusic?did=${g_did}&search_key=${search_key}&name=${name}`, 
      function(data, status) {
        res = JSON.stringify(data);
        console.log(`download music ${search_key}: ${res}, ${status}`);
        addDataToList("下载", data.ret);
    });
  });

  $("#volume").on('input', function () {
    var value = $(this).val();
    $("#volume-value").text(value);
    $.ajax({
      type: "POST",
      url: "/setvolume",
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify({did: g_did, volume: value}),
      success: () => {
      },
      error: () => {
      }
    });
  });

  $("#status").on("click", () => {
    sendMessage("test");
  });

  // 切换列表的可见性
  $("#toggle-log").on("click", () => {
    var listContainer = document.querySelector('.hidden-list-container');
    if (listContainer.style.display === '') {
      listContainer.style.display = 'block';
    } else {
      listContainer.style.display = '';
    }
  });
  // end bind
  
  // == function definitions
  function init_device(data) {
    if (!data || !data.mi_did) {
      console.log('No device information available');
      return;
    }

    localStorage.setItem('mi_did', data.mi_did);

    var did = localStorage.getItem('cur_did');
    var dids = [];
    if (data.mi_did != null) {
      dids = data.mi_did.split(',');
    }
    console.log('cur_did', did);
    console.log('dids', dids);
    if ((dids.length > 0) && (did == null || did == "" || !dids.includes(did))) {
      did = dids[0];
      localStorage.setItem('cur_did', did);
    }
    window.did = did;
    console.log('cur_did', did);
    g_did = did;

    // 拉取声音
    $.get(`/getvolume?did=${did}`, function(data, status) {
      console.log(data, status, data["volume"]);
      $("#volume").val(data.volume);
      $("#volume-value").text(data.volume);
    });

    // 拉取版本
    $.get("/getversion", function(data, status) {
      console.log(data, status, data["version"]);
      $("#version").text(`(${data.version})`);
    });
  }

  function sendcmd(cmd) {
    $.ajax({
      type: "POST",
      url: "/cmd",
      contentType: "application/json",
      data: JSON.stringify({did: g_did, cmd: cmd}),
      success: () => {
        // 请求成功时执行的操作
      },
      error: () => {
        // 请求失败时执行的操作
      }
    });
  }

  function append_op_button_name(name) {
    append_op_button(name, name);
  }

  function append_op_button(name, cmd) {
    // 创建按钮
    const $button = $("<button>");
    $button.text(name);
    $button.attr("type", "button");

    // 设置按钮点击事件
    $button.on("click", () => {
      sendcmd(cmd);
    });

    // 添加按钮到容器
    $container.append($button);
  }

  function build_music_list(){
    $.get("/musiclist", function(data, status) {
      console.log(`build music list: ${data}, ${status}`);
      $.each(data, function(key, value) {
        let cnt = value.length;
        if (key === "所有歌曲") {
          g_songs = value;
        }
      });
      renderPlaylist();
    });
  }
  
  function renderPlaylist() {
      g_songs.forEach((song, index) => {
          let tr = document.createElement('tr');
          let th = document.createElement('th');
          th.textContent = `${index + 1}. ${song}`;
          th.dataset.index = index;
          tr.appendChild(th);
          th = document.createElement('th');
          th.textContent = `offline`;
          th.dataset.index = index;
          tr.appendChild(th);
          let tbody = musicList.getElementsByTagName('tbody');
          tbody[0].appendChild(tr);
      });
  }

  function playSong(event) {
      let selectedIndex = event.target.dataset.index;
      highlightCurrentSong(selectedIndex);
      let song = g_songs[selectedIndex];
      console.log(`Playing song: ${song}`);
      let cmd = "播放歌曲"+song+"|"+song;
      sendcmd(cmd);
  }

  function highlightCurrentSong(index) {
      let currentPlaying = document.querySelector('.playing');
      if (currentPlaying) {
          currentPlaying.classList.remove('playing');
      }
      var cur = musicList.children[index];
      cur.classList.add('playing');
      setTimeout(() => {
        scrollToChild(musicList, cur);
      }, 500);
  }

  function selectCurrentSong(song) {
    const musicListItems = Array.from(document.querySelectorAll('#musicList li'));
    const itemTexts = musicListItems.map(item => item.textContent);
    const targetText = song;
    const index = itemTexts.findIndex(item => {
      return item.includes(targetText);
    });
    if (index !== -1) {
      highlightCurrentSong(index);
    } else {
      console.log(`文本 '${targetText}' 不在 musicList`);
    }
  }

  function scrollToChild(parent, child) {
    const offsetTop = child.offsetTop - parent.offsetTop;
    parent.scrollTop = offsetTop;
  }

  // 发送消息到后端
  function sendMessage(data) {
    console.log("Connected: " + socket.connected);
    socket.timeout(3000).emit('message', data, (err, res)=>{
      if(err)
        console.log("sendMessage failed: "  + err);
      else
        console.log("response: " + res);
    });
  }

  // 添加数据到列表的函数
  function addDataToList(data1, data2) {
    var listContainer = document.querySelector('.hidden-list');
    var newListItem = document.createElement('li');
    var dataSpan1 = document.createElement('span');
    var dataSpan2 = document.createElement('span');
    dataSpan1.textContent = data1;
    dataSpan2.textContent = data2;
    dataSpan2.setAttribute('title', data2);
    newListItem.appendChild(dataSpan1);
    newListItem.appendChild(dataSpan2);
    if(listContainer.children.length > 1)
      listContainer.insertBefore(newListItem, listContainer.children[1]);
    else
      listContainer.appendChild(newListItem);
  }
  // end function

  // == player buttons
  const playButtonPos = {
    x: 200,
    y: 373,
    width: 132,
    height: 132
  };
  const stopButtonPos = {
      x: 0,
      y: 370,
      width: 130,
      height: 130
  };
  const pauseButtonPos = {
    x: 0,
    y: 180,
    width: 132,
    height: 132
  };
  const preButtonPos = {
      x: 420,
      y: 0,
      width: 130,
      height: 130
  };
  const nextButtonPos = {
    x: 420,
    y: 370,
    width: 130,
    height: 130
  };
  const refreshButtonPos = {
    x: 390,
    y: 190,
    width: 130,
    height: 130
  };
  const listButtonPos = {
    x: 200,
    y: 0,
    width: 130,
    height: 130
  };
   
  function showButton(buttonPos, $button, cmd) {
      const canvas = $('#button-canvas')[0];
      const ctx = canvas.getContext('2d');
      const controlImage = $('#playerButtonsImg')[0];
      canvas.width = buttonPos.width;
      canvas.height = buttonPos.height;
      ctx.drawImage(controlImage, buttonPos.x, buttonPos.y, buttonPos.width, buttonPos.height, 0, 0, buttonPos.width, buttonPos.height);
      const dataURL = canvas.toDataURL();
      $button.css('backgroundImage', `url(${dataURL})`);
      $button.on("click", () => {
        sendcmd(cmd);
      });
  }
  function showButtonWithAction(buttonPos, $button, action) {
    const canvas = $('#button-canvas')[0];
    const ctx = canvas.getContext('2d');
    const controlImage = $('#playerButtonsImg')[0];
    canvas.width = buttonPos.width;
    canvas.height = buttonPos.height;
    ctx.drawImage(controlImage, buttonPos.x, buttonPos.y, buttonPos.width, buttonPos.height, 0, 0, buttonPos.width, buttonPos.height);
    const dataURL = canvas.toDataURL();
    $button.css('backgroundImage', `url(${dataURL})`);
    $button.on("click", () => {
      action();
    });
  }
  function refreshButton() {
      showButton(stopButtonPos, $("#stopButton"), "停止播放");
      showButton(playButtonPos, $("#playButton"), "播放歌曲");
      showButton(pauseButtonPos, $("#pauseButton"), "暂停播放"); // test
      showButton(preButtonPos, $("#preButton"), "上一首"); // test
      showButton(nextButtonPos, $("#nextButton"), "下一首");
      showButtonWithAction(refreshButtonPos, $("#refreshBtn"), () => {
        build_music_list();
      });
      showButtonWithAction(listButtonPos, $("#listButton"), () => {
        const listContainer = $("#playlistContainer")[0];
        if (listContainer.style.display === 'none') {
          listContainer.style.display = 'block';
        } else {
          listContainer.style.display = 'none';
        }
      });
  }
  // == end

  // == initialize 
  // $container=$("#cmds");
  // append_op_button_name("下一首");
  // append_op_button_name("全部循环");
  // append_op_button_name("停止播放");
  // append_op_button_name("单曲循环");
  // append_op_button_name("播放歌曲");
  // append_op_button_name("随机播放");

  // $container.append($("<hr>"));
  // append_op_button_name("10分钟后关机");
  // append_op_button_name("30分钟后关机");
  // append_op_button_name("60分钟后关机");
  refreshButton();

  // pull setting and init device
  $.get("/getsetting", function(data, status) {
    console.log(data, status);
    init_device(data);
  });
  // create music list
  $musicList=$("#musicList");
  build_music_list();

  // ==end initialize
});
