window.App = window.App || {};
App.Components = App.Components || {};
App.Stores = App.Stores || {};

App.Components.Queues = React.createClass({
  displayName: "Queues",

  getInitialState: function() {
    return {
      queues: []
    };
  },

  componentDidMount: function() {
    var url = $("#queues").data('url');

    setInterval(function() {
      this.fetchStats(url);
    }.bind(this), 1000);
  },

  fetchStats: function(url) {
    $.getJSON(url).done(function(data, status, xhr) {
      this.setState({queues: data});
    }.bind(this));
  },

  render: function() {
    var queueNodes = this.state.queues.map(function(queue) {
      return (
        React.createElement(App.Components.Queue, {
          queue: queue,
          key: queue.name
        })
      )
    }.bind(this));

    if (queueNodes.length === 0) {
      return React.createElement("em", {className: "text-muted"}, "No queues found.");
    }

    return React.createElement("table", {className: "table table-hover table-bordered"},

      React.createElement("thead", null,
        React.createElement("tr", null,
          React.createElement("td", null, "Name"),
          React.createElement("td", {className: "text-center"}, "Workers"),
          React.createElement("td", {className: "text-center"}, "Enqueued"),
          React.createElement("td", {className: "text-center"}, "Processed"),
          React.createElement("td", {className: "text-center"}, "Total")
        )
      ),

      React.createElement("tbody", null, queueNodes)
    )
  }
});

App.Components.Queue = React.createClass({
  displayName: "Queue",

  render: function() {
    return React.createElement("tr", null,
      React.createElement("td", null, this.props.queue.name),
      React.createElement("td", {className: "text-center"}, this.props.queue.workers),
      React.createElement("td", {className: "text-center"}, this.props.queue.enqueued),
      React.createElement("td", {className: "text-center"}, this.props.queue.processed),
      React.createElement("td", {className: "text-center"}, this.props.queue.total)
    )
  }
});

ReactDOM.render(React.createElement(App.Components.Queues), document.getElementById("queues"));

