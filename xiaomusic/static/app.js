$(function(){
  $container=$("#cmds");
  append_op_button_name("下一首");
  append_op_button_name("全部循环");
  append_op_button_name("停止播放");
  append_op_button_name("单曲循环");
  append_op_button_name("播放歌曲");
  append_op_button_name("随机播放");

  $container.append($("<hr>"));

  append_op_button_name("10分钟后关机");
  append_op_button_name("30分钟后关机");
  append_op_button_name("60分钟后关机");

  // 拉取声音
  sendcmd("get_volume#");
  $.get("/getvolume", function(data, status) {
    console.log(data, status, data["volume"]);
    $("#volume").val(data.volume);
  });

  // 拉取版本
  $.get("/getversion", function(data, status) {
    console.log(data, status, data["version"]);
    $("#version").text(`(${data.version})`);
  });


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

  $("#play").on("click", () => {
    var search_key = $("#music-name").val();
    var filename=$("#music-filename").val();
    let cmd = "播放歌曲"+search_key+"|"+filename;
    sendcmd(cmd);
  });
  $("#search").on("click", () => {
    var search_key = $("#music-name").val();
    var filename=$("#music-filename").val();
    let cmd = "下载歌曲"+search_key+"|"+filename;
    sendcmd(cmd);
  });

  $("#volume").on('input', function () {
    var value = $(this).val();
    sendcmd("set_volume#"+value);
  });

  function sendcmd(cmd) {
    $.ajax({
      type: "POST",
      url: "/cmd",
      contentType: "application/json",
      data: JSON.stringify({cmd: cmd}),
      success: () => {
        // 请求成功时执行的操作
      },
      error: () => {
        // 请求失败时执行的操作
      }
    });
  }

  // 监听输入框的输入事件
  $("#music-name").on('input', function() {
    var inputValue = $(this).val();
    // 发送Ajax请求
    $.ajax({
      url: "searchmusic", // 服务器端处理脚本
      type: "GET",
      dataType: "json",
      data: {
        name: inputValue
      },
      success: function(data) {
        // 清空datalist
        $("#autocomplete-list").empty();
        // 添加新的option元素
        $.each(data, function(i, item) {
          $('<option>').val(item).appendTo("#autocomplete-list");
        });
      }
    });
  });

  function get_playing_music() {
    $.get("/playingmusic", function(data, status) {
      console.log(data);
      $("#playering-music").text(data);
      selectCurrentSong(data);
    });
  }

  function get_downloading_music() {
    $.get("/downloadingmusic", function(data, status) {
      console.log(data);
      $("#downloading-music").text(data);
    });
  }

  // 每3秒获取下正在播放的音乐
  get_playing_music();
  setInterval(() => {
    get_playing_music();
    get_downloading_music();
  }, 3000);

  // create music list
  $musicList=$("#musicList");
  var songs = [
    /* 这里添加歌曲对象，包含歌曲名称、艺术家等信息 */
  ];
  
  function build_music_list(){
    $.get("/getmusiclist", function(data, status) {
      console.log(data);
      songs = JSON.parse(data);
      renderPlaylist();
    });
  }
  
  function renderPlaylist() {
      musicList.innerHTML = '';
      songs.forEach((song, index) => {
          let li = document.createElement('li');
          //li.textContent = `${index + 1}. ${song.name} - ${song.artist}`;
          li.textContent = `${index + 1}. ${song}`;
          li.dataset.index = index;
          li.addEventListener('dblclick', playSong);
          musicList.appendChild(li);
      });
  }

  function playSong(event) {
      let selectedIndex = event.target.dataset.index;
      highlightCurrentSong(selectedIndex);
      //console.log(`Playing song: ${songs[selectedIndex].name}`);
      let song = songs[selectedIndex];
      console.log(`Playing song: ${song}`);
      let cmd = "播放歌曲"+song+"|"+song;
      sendcmd(cmd);
  }

  function highlightCurrentSong(index) {
      let currentPlaying = document.querySelector('.playing');
      if (currentPlaying) {
          currentPlaying.classList.remove('playing');
      }
      musicList.children[index].classList.add('playing');
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
      musicListItems[index].scrollIntoView({ behavior: 'smooth', block: 'center' });
    } else {
      console.log(`文本 '${targetText}' 不在 musicList`);
    }
  }

  $("#refreshButton").on("click", () => {
    build_music_list();
  });

  build_music_list();
});
