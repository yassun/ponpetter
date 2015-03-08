var Container = React.createClass({

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
  componentDidMount: function() {
    this.loadPonpeFromServer();
  },

  render: function() {
    return (
      <div className="container">
        <Header />
        <PonpeCnt ponpe_cnt={this.state.data.ponpe_cnt} />
        <Graph />
        <TweetButton />
        <Tweets tweets={this.state.data.tweets}  />
        <Footer />
      </div>
    );
  }
});

var Header = React.createClass({
  render: function() {
    return (
      <div className="header">
        <h3 className="text-muted">
            Ponpetter
            <span className="pull-right">
                by <a href="https://twitter.com/_yasuun_" target="_blank">@_Yasuun_</a>
            </span>
        </h3>
      </div>
    );
  }
});

var PonpeCnt = React.createClass({
  render: function() {
    return (
      <div className="counter text-center">
        <h2>本日のポンペ数 <span className="ponpe-cnt">{this.props.ponpe_cnt}人</span></h2>
      </div>
    );
  }
});

var Graph = React.createClass({

  render: function() {
    return (
      <div id="chart" className="text-center">
        <canvas id="myChart" width="700" height="200"></canvas>
      </div>
    );
  }
});

var TweetButton = React.createClass({
  render: function() {
    return (
     <div className="tweet-btn">
        <a href="https://twitter.com/intent/tweet?button_hashtag=ponpetter&text=%E3%81%8A%E8%85%B9%E7%97%9B%E3%81%84%E3%80%82"
        className="twitter-hashtag-button" data-lang="ja" data-size="large" data-url="http://ponpetter.herokuapp.com/">Tweet #ponpetter</a>
      </div>
    );
  }
});

var Tweets = React.createClass({
  render: function() {
    if (!this.props.tweets) {
      return (
        <div className="tweets row" />
      );
    }
    var tweetNodes = this.props.tweets.map(function(tweet){
      return (
          <Tweet tweet={tweet}/>
        );
    });
    return (
      <div className="tweets row">
        {tweetNodes}
      </div>
    );
  }
});

var Tweet = React.createClass({
  render: function() {
    return (
      <div className="tweet col-lg-12">
        <span className="img"><img src={this.props.tweet.img}/></span>
        <span className="autor"><a href={"https://twitter.com/" + this.props.tweet.autor} target="_blank">@{this.props.tweet.autor}</a></span>
        <span className="body">{this.props.tweet.text}</span>
        <span className="time"><a href={"https://twitter.com/" + this.props.tweet.autor + "/status/" + this.props.tweet.id} target="_blank">{this.props.tweet.time}</a></span>
      </div>
    );
  }
});

var Footer = React.createClass({
  render: function() {
    return (
      <footer className="footer">
        <p></p>
      </footer>
    );
  }
});

React.render(
  <Container url="ponpe.json"/>,
  document.getElementById('content')
);
