$(document).ready(function() {
  $("input[type=text]").addClass("text");

  $("select[name=_site]").change(function() {
    var _site = $("select[name=_site]").val();
    var site = _site.substr(0, _site.indexOf(':'));
    var category = _site.substr(_site.indexOf(':')+1);
    
    $("input[name=site]").val(site);
    $("input[name=category]").val(category);
    
    switch (site) {
      case "mefi":  $("body").css("background-color", "#006699"); break;
      case "askme": $("body").css("background-color", "#426746"); break;
      case "music": $("body").css("background-color", "#333333"); break;
      case "meta":  $("body").css("background-color", "#666666"); break;
    }
    
    if (site == "askme") {
      $("form#best").show();
    }
    else {
      $("form#best").hide();
    }
  });

  $("input[name=_start_date]").change(function() {
    $("input[name=start_date]").val($("input[name=_start_date]").val());
  });

  $("input[name=_end_date]").change(function() {
    $("input[name=end_date]").val($("input[name=_end_date]").val());
  });
  
  if (!$.browser.webkit) {
    $('input[placeholder]').each(function(i) {
      var item = $(this);
      var text = item.attr('placeholder');
      var form = item.parents('form:first');

      if (item.val() === '') {
        item.val(text);
        item.css('color', '#888');
      }
      
      item.bind('focus.placeholder', function(event) {
        if (item.val() === text) {
          item.val('');
        }
        item.css('color', '');
      });
      
      item.bind('blur.placeholder', function(event) {
        if (item.val() === '') {
          item.val(text);
          item.css('color', '#888');
        }
      });
      
      form.bind("submit.placeholder", function(event) {
        if (item.val() === text) {
          item.val("");
        }
      });
    });
  }
});

function setupInfiniteScroll() {
  var nextPageRequested = false;
  var nextPage = 1;

  $(window).scroll(function() {
    if (nextPageRequested || nextPage == 0)
      return;

    table = $(".results");

    if ($(window).scrollTop()+$(window).height() < table.offset().top+table.height())
      return;

    nextPageRequested = true;
    table.after("<div id='loading'>...</div>")
      
    $.ajax({
      url: (window.location.href + "&page=" + nextPage),
      dataType: "html",
      success: function (doc) {
        rows = $(doc).filter(".results").find("tr:gt(0)");
        if (rows.length) {
          $(".results > tbody:last").append(rows);
          ++nextPage;
        }
        else {
          nextPage = 0;
        }
      },
      complete: function() { 
        $("div#loading").remove();
        nextPageRequested = false;
      }
    });
  });
}

// Google Analytics.

var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-616054-3']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
