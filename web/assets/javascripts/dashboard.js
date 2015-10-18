window.App = window.App || {};
App.Components = App.Components || {};
App.Stores = App.Stores || {};

App.Stores.Queues = {
  startPoll: function(url) {
    setInterval(function() {
      $.getJSON(url).done(function(data, status, xhr) {
        App.Stores.Queues.triggerQueuesUpdate(data);
      });
    }, 1000);
  },

  triggerQueuesUpdate: function(queues) {
    evt = new CustomEvent("queuesUpdate", {
      detail: {
        queues: queues,
      }
    });

    window.dispatchEvent(evt);
  }
}

App.Components.Queues = React.createClass({
  displayName: "Queues",

  getInitialState: function() {
    return {
      queues: {}
    };
  },

  componentDidMount: function() {
    this.listenForQueuesUpdate();
  },
  componentWillUnmount: function() {
    window.removeEventListener("queuesUpdate", this.handleQueuesUpdate, false);
  },
  listenForQueuesUpdate: function() {
    window.addEventListener("queuesUpdate", this.handleQueuesUpdate, false);
  },

  handleQueuesUpdate: function(evt) {
    var queues = evt.detail.queues;
    this.setState({queues: queues});
  },

  render: function() {
    var queueNodes = Object.keys(this.state.queues).map(function(queueName) {
      return (
        React.createElement(App.Components.Queue, {
          name: queueName,
          stats: this.state.queues[queueName],
          key: queueName
        })
      )
    }.bind(this));

    if (queueNodes.length === 0) {
      return React.createElement("em", {className: "text-muted"}, "No queues found.");
    }

    return React.createElement("table", {className: "table table-hover table-bordered"},

      React.createElement("thead", null,
        React.createElement("tr", null,
          React.createElement("td", null, null),
          React.createElement("td", {className: "text-center", colSpan: 3}, "Workers"),
          React.createElement("td", {className: "text-center", colSpan: 2}, "Jobs")
        ),
        React.createElement("tr", null,
          React.createElement("td", null, "Name"),
          React.createElement("td", {className: "text-center"}, "Idle"),
          React.createElement("td", {className: "text-center"}, "Busy"),
          React.createElement("td", {className: "text-center"}, "Total"),
          React.createElement("td", {className: "text-center"}, "Enqueued"),
          React.createElement("td", {className: "text-center"}, "Processed")
        )
      ),

      React.createElement("tbody", null, queueNodes)
    )
  }
});

App.Components.Queue = React.createClass({
  displayName: "Queue",

  props: {
    name: React.PropTypes.string.isRequired,
    stats: React.PropTypes.object.isRequired,
    key: React.PropTypes.string.isRequired
  },

  render: function() {
    return React.createElement("tr", null,
      React.createElement("td", null, this.props.name),
      React.createElement("td", {className: "text-center"}, this.props.stats.workers.idle),
      React.createElement("td", {className: "text-center"}, this.props.stats.workers.busy),
      React.createElement("td", {className: "text-center"}, this.props.stats.workers.total),
      React.createElement("td", {className: "text-center"}, this.props.stats.jobs.enqueued),
      React.createElement("td", {className: "text-center"}, this.props.stats.jobs.processed)
    )
  }
});

App.Components.Graph = React.createClass({
  displayName: "Graph",
  graph: null,

  getInitialState: function() {
    return {
      graphData: [{label: "FakeJob", values: []}]
    };
  },

  componentDidMount: function() {
    this.listenForQueuesUpdate();
    this.initGraph();
  },
  componentWillUnmount: function() {
    window.removeEventListener("queuesUpdate", this.handleQueuesUpdate, false);
  },
  listenForQueuesUpdate: function() {
    window.addEventListener("queuesUpdate", this.handleQueuesUpdate, false);
  },
  handleQueuesUpdate: function(evt) {
    var queues = evt.detail.queues;
    this.pushGraphData(queues);
  },
  pushGraphData: function(queues) {
    var next = [];
    Object.keys(queues).map(function(queueName) {
      next.push({
        time: ((new Date()).getTime() / 1000)|0,
        y: queues[queueName].jobs.enqueued
      });
    });

    this.graph.push(next);
  },
  initGraph: function() {
    var el = this.refs.graph;
    this.graph = $(el).epoch({
      type: 'time.line',
      data: this.state.graphData,
      axes: ['right', 'left']
    });
  },
  render: function() {
    return React.createElement("div", {className: "graph epoch", style: {width: "100%", height: "200px"}, ref: "graph"}, null)
  }
});

ReactDOM.render(React.createElement(App.Components.Queues), document.getElementById("queues"));
ReactDOM.render(React.createElement(App.Components.Graph), document.getElementById("graph-container"));

var queuesUrl = $("#queues").data('url');
App.Stores.Queues.startPoll(queuesUrl);
