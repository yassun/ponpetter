var Container = React.createClass({displayName: "Container",

  loadPonpeFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      success: function(data) {
        this.setState({data: data});
        this.drawGraph();
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  drawGraph: function() {
    var data = {
      labels : this.state.data.graph.labels,
      datasets : [
        {
          fillColor : "rgba(0,180,255,0.1)",
          strokeColor : "#66ccff",
          pointColor : "#66ccff",
          pointStrokeColor : "#fff",
          data : this.state.data.graph.values
        }
      ]
    };

    var ctx = document.getElementById("myChart").getContext("2d");
    new Chart(ctx).Line(data,{
      scaleOverlay : false,
      scaleLineColor : "#ccc",
      scaleLineWidth : 1,
      scaleShowLabels : true,
      scaleLabel : "<%=value%>",
      scaleFontFamily : "'Arial'",
      scaleFontSize : 11,
      scaleFontStyle : "normal",
      scaleFontColor : "#ccc",
      scaleShowGridLines : false,
      scaleGridLineColor : "#ccc",
      scaleGridLineWidth : 1,
      bezierCurve : false,
      pointDot : true,
      pointDotRadius : 6,
      pointDotStrokeWidth : 0,
      datasetStroke : true,
      datasetStrokeWidth : 3,
      datasetFill : true,
      animation : true,
      animationSteps : 60,
      animationEasing : "easeOutQuart",
      onAnimationComplete : null
    });

  },
  onMessageWs : function () {
    var ws = new WebSocket('ws://' + window.document.location.host);
    ws.onmessage = function(e) {
      var data = JSON.parse(e.data);
      this.setState({data: data});
    }.bind(this);
  },
  componentDidMount: function() {
    this.loadPonpeFromServer();
    this.onMessageWs();
  },

  render: function() {
    return (
      React.createElement("div", {className: "container"}, 
        React.createElement(Header, null), 
        React.createElement(PonpeCnt, {ponpe_cnt: this.state.data.ponpe_cnt}), 
        React.createElement(Graph, null), 
        React.createElement(TweetButton, null), 
        React.createElement(Tweets, {tweets: this.state.data.tweets}), 
        React.createElement(Footer, null)
      )
    );
  }
});

var Header = React.createClass({displayName: "Header",
  render: function() {
    return (
      React.createElement("div", {className: "header"}, 
        React.createElement("h3", {className: "text-muted"}, 
            "Ponpetter", 
            React.createElement("span", {className: "pull-right"}, 
                "by ", React.createElement("a", {href: "https://twitter.com/_yasuun_", target: "_blank"}, "@_Yasuun_")
            )
        )
      )
    );
  }
});

var PonpeCnt = React.createClass({displayName: "PonpeCnt",
  render: function() {
    return (
      React.createElement("div", {className: "counter text-center"}, 
        React.createElement("h2", null, "本日のポンペ数 ", React.createElement("span", {className: "ponpe-cnt"}, this.props.ponpe_cnt, "人"))
      )
    );
  }
});

var Graph = React.createClass({displayName: "Graph",
  render: function() {
    return (
      React.createElement("div", {id: "chart", className: "text-center"}, 
        React.createElement("canvas", {id: "myChart", width: "700", height: "200"})
      )
    );
  }
});

var TweetButton = React.createClass({displayName: "TweetButton",
  render: function() {
    return (
     React.createElement("div", {className: "tweet-btn"}, 
        React.createElement("a", {href: "https://twitter.com/intent/tweet?button_hashtag=ponpetter&text=%E3%81%8A%E8%85%B9%E7%97%9B%E3%81%84%E3%80%82", 
        className: "twitter-hashtag-button", "data-lang": "ja", "data-size": "large", "data-url": "http://ponpetter.herokuapp.com/"}, "Tweet #ponpetter")
      )
    );
  }
});

var Tweets = React.createClass({displayName: "Tweets",
  render: function() {
    if (!this.props.tweets) {
      return (
        React.createElement("div", {className: "tweets row"})
      );
    }
    var tweetNodes = this.props.tweets.map(function(tweet){
      return (
          React.createElement(Tweet, {tweet: tweet})
        );
    });
    return (
      React.createElement("div", {className: "tweets row"}, 
        tweetNodes
      )
    );
  }
});

var Tweet = React.createClass({displayName: "Tweet",
  render: function() {
    return (
      React.createElement("div", {className: "tweet col-lg-12"}, 
        React.createElement("span", {className: "img"}, React.createElement("img", {src: this.props.tweet.img})), 
        React.createElement("span", {className: "autor"}, React.createElement("a", {href: "https://twitter.com/" + this.props.tweet.autor, target: "_blank"}, "@", this.props.tweet.autor)), 
        React.createElement("span", {className: "body"}, this.props.tweet.text), 
        React.createElement("span", {className: "time"}, React.createElement("a", {href: "https://twitter.com/" + this.props.tweet.autor + "/status/" + this.props.tweet.id, target: "_blank"}, this.props.tweet.time))
      )
    );
  }
});

var Footer = React.createClass({displayName: "Footer",
  render: function() {
    return (
      React.createElement("footer", {className: "footer"}, 
        React.createElement("p", null)
      )
    );
  }
});

React.render(
  React.createElement(Container, {url: "ponpe.json"}),
  document.getElementById('content')
);
