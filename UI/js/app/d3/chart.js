
var json = [{"articles": [[2010, 6], [2011, 10], [2012, 11], [2013, 23], [2006, 1]], "total": 51, "name": "The Journal of neuroscience : the official journal of the Society for Neuroscience"}, {"articles": [[2008, 1], [2010, 3], [2011, 4], [2012, 17], [2013, 10]], "total": 35, "name": "Nature neuroscience"}, {"articles": [[2009, 1], [2010, 2], [2011, 8], [2012, 13], [2013, 11]], "total": 35, "name": "PloS one"}, {"articles": [[2007, 1], [2009, 3], [2010, 5], [2011, 7], [2012, 9], [2013, 9]], "total": 34, "name": "Nature"}, {"articles": [[2009, 2], [2010, 3], [2011, 4], [2012, 8], [2013, 9]], "total": 26, "name": "Neuron"}, {"articles": [[2009, 2], [2010, 2], [2011, 3], [2012, 9], [2013, 7]], "total": 23, "name": "Proceedings of the National Academy of Sciences of the United States of America"}, {"articles": [[2008, 1], [2010, 5], [2011, 10], [2012, 3], [2013, 3]], "total": 22, "name": "Nature methods"}, {"articles": [[2007, 1], [2009, 1], [2010, 3], [2011, 4], [2012, 4], [2013, 8]], "total": 21, "name": "Current opinion in neurobiology"}, {"articles": [[2006, 1], [2009, 3], [2010, 4], [2011, 1], [2012, 2], [2013, 7]], "total": 18, "name": "Science (New York, N.Y.)"}, {"articles": [[2010, 2], [2011, 4], [2012, 6], [2013, 4], [2007, 1]], "total": 17, "name": "Current biology : CB"}, {"articles": [[2010, 1], [2011, 3], [2012, 8], [2013, 3]], "total": 15, "name": "Journal of neurophysiology"}, {"articles": [[2009, 1], [2012, 4], [2013, 9]], "total": 14, "name": "Frontiers in neural circuits"}, {"articles": [[2012, 1], [2013, 13]], "total": 14, "name": "Brain research"}, {"articles": [[2009, 2], [2010, 1], [2011, 2], [2013, 8]], "total": 13, "name": "Frontiers in molecular neuroscience"}, {"articles": [[2008, 1], [2010, 2], [2011, 3], [2012, 3], [2013, 4]], "total": 13, "name": "The Journal of biological chemistry"}, {"articles": [[2009, 1], [2010, 1], [2011, 8], [2012, 2]], "total": 12, "name": "Conference proceedings : ... Annual International Conference of the IEEE Engineering in Medicine and Biology Society. IEEE Engineering in Medicine and Biology Society. Conference"}, {"articles": [[2012, 12]], "total": 12, "name": "Progress in brain research"}, {"articles": [[2009, 1], [2010, 1], [2012, 4], [2013, 6]], "total": 12, "name": "Journal of neuroscience methods"}, {"articles": [[2011, 3], [2012, 5], [2013, 3]], "total": 11, "name": "Journal of visualized experiments : JoVE"}, {"articles": [[2011, 1], [2012, 2], [2013, 8]], "total": 11, "name": "Neuroscience research"}, {"articles": [[2008, 1], [2010, 2], [2011, 5], [2012, 2]], "total": 10, "name": "Cell"}, {"articles": [[2012, 10]], "total": 10, "name": "Biological psychiatry"}, {"articles": [[2009, 1], [2011, 1], [2012, 5], [2013, 1]], "total": 8, "name": "The Journal of physiology"}, {"articles": [[2010, 2], [2012, 4], [2013, 1]], "total": 7, "name": "Nature protocols"}, {"articles": [[2013, 7]], "total": 7, "name": "Behavioural brain research"}, {"articles": [[2011, 5], [2013, 1]], "total": 6, "name": "Experimental physiology"}, {"articles": [[2011, 1], [2012, 1], [2013, 4]], "total": 6, "name": "Neuropharmacology"}, {"articles": [[2011, 1], [2012, 2], [2013, 2]], "total": 5, "name": "Neuroscience"}, {"articles": [[2011, 2], [2013, 3]], "total": 5, "name": "Nature communications"}, {"articles": [[2009, 1], [2010, 1], [2011, 1], [2012, 1], [2013, 1]], "total": 5, "name": "Neurosurgery"}];

function drawChart() {

    function truncate (str, maxLength, suffix) {
    if (str.length > maxLength) {
      str = str.substring(0, maxLength + 1);
      str = str.substring(0, Math.min(str.length, str.lastIndexOf(" ")));
      str = str + suffix;
    }
    return str;
  }

  var margin = { top: 20, right: 200, bottom: 0, left: 20 },
      width = 300,
      height = 650,
      start_year = 2004,
      end_year = 2013;

  var c = d3.scale.category20c();
  var x = d3.scale.linear().range([0, width]);
  var xAxis = d3.svg.axis().scale(x).orient("top");
  xAxis.tickFormat(d3.format("0000"));

  var svg = d3.select("#chart").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .style("margin-left", margin.left + "px")
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  x.domain([start_year, end_year]);
  var xScale = d3.scale.linear()
    .domain([start_year, end_year])
    .range([0, width]);

  svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + 0 + ")")
    .call(xAxis);

  for (var j = 0; j < json.length; j++) {
    var g = svg.append("g").attr("class","journal");

    var circles = g.selectAll("circle")
      .data(json[j]['articles'])
      .enter()
      .append("circle");

    var text = g.selectAll("text")
      .data(json[j]['articles'])
      .enter()
      .append("text");

    var rScale = d3.scale.linear()
      .domain([0, d3.max(json[j]['articles'], function(d) { return d[1]; })])
      .range([2, 9]);

    circles
      .attr("cx", function(d, i) { return xScale(d[0]); })
      .attr("cy", j*20+20)
      .attr("r", function(d) { return rScale(d[1]); })
      .style("fill", function(d) { return c(j); });

    text
      .attr("y", j*20+25)
      .attr("x",function(d, i) { return xScale(d[0])-5; })
      .attr("class","value")
      .text(function(d){ return d[1]; })
      .style("fill", function(d) { return c(j); })
      .style("display","none");

    g.append("text")
      .attr("y", j*20+25)
      .attr("x",width+20)
      .attr("class","label")
      .text(truncate(json[j]['name'],30,"..."))
      .style("fill", function(d) { return c(j); })
      .on("mouseover", mouseover)
      .on("mouseout", mouseout);
  };

  function mouseover(p) {
    var g = d3.select(this).node().parentNode;
    d3.select(g).selectAll("circle").style("display","none");
    d3.select(g).selectAll("text.value").style("display","block");
  }

  function mouseout(p) {
    var g = d3.select(this).node().parentNode;
    d3.select(g).selectAll("circle").style("display","block");
    d3.select(g).selectAll("text.value").style("display","none");
  }


};

setTimeout(drawChart, 500);



