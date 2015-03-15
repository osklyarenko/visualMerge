
VisualMerge.controller('ChartController', function($scope) {
  $scope.data = $scope.data || [];

  var $chartCnt = $('.chart-cnt'),
      margin = { top: 20, left: 20 },
      labelHeight = 20,
      labelWidth = 360,
      chartWidth = $chartCnt.width() - labelWidth,
      chartHeight = 30;      

  function _setRange(start, end) {
    $scope.start = start || 0;
    $scope.end = end || 100;
  }

  function _render(element) {
    var startTime = new Date;
    var start = $scope.start;
    var end = $scope.end;

    var meta = $scope.meta;
    var data = $scope.documents;
    
    var itemsCount = data.length;

    var fragment = document.createDocumentFragment();
    var c = d3.scale.category20c();
    var x = d3.scale.linear().range([0, chartWidth]);
    var xAxis = d3.svg.axis().scale(x).orient("top");
    xAxis.tickFormat(d3.format("0000"));

    var svg = d3.select(fragment).append("svg")
      .attr("width", chartWidth + labelWidth)
      .attr("height", chartHeight + margin.top + itemsCount * labelHeight)
      //.style("position", "absolute")
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain([end, start]);
    var xScale = d3.scale.linear()
      .domain([end, start])
      .range([0, chartWidth]);

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + 0 + ")")
      .call(xAxis);

    var minChangeSize = 1;
    var maxChangeSize = 1;

    var dataItemsCount = data.length;
    for(var j = 0; j < dataItemsCount; j++) {
      var dataItem = data[j];
      var articles = dataItem.articles;

      var articlesCount = articles.length;
      for (var k = 0; k < articlesCount; k++) {
        var articleItem = articles[k];
        var value = articleItem[1];

        if (minChangeSize > value) {
          minChangeSize = value;
        }

        if (maxChangeSize < value) {
          maxChangeSize = value;
        }
      }
    }

    for (var j = 0; j < itemsCount; j++) {
      var item = data[j];
      var name = item['name'];
      var value = item['articles'];
      var fullName = item['full_name'];
      var color = item['color'];

      var g = svg.append("g").attr("class", "journal");

      var circles = g.selectAll("circle")
        .data(value)
        .enter()
        .append("circle");

      var text = g.selectAll("text")
        .data(value)
        .enter()
        .append("text");

      var rScale = d3.scale.linear()
        .domain([minChangeSize, maxChangeSize])
        .range([5, 20]);

      circles
        .attr("cx", function(d, i) { return xScale(d[0]); })
        .attr("cy", j*20+20)
        .attr("r", function(d) { 
          console.log(d[1]);
          return rScale(d[1]); 
        })
        .style("fill", function(d) { return color || c(j); });

      text
        .attr("y", j*20+25)
        .attr("x",function(d, i) { return xScale(d[0])-5; })
        .attr("class","value")
        .text(function(d){ return d[1]; })
        .style("fill", function(d) { return c(j); })
        .style("display","none");

      g.append("text")
        .attr("y", j*20+25)
        .attr("x", chartWidth+20)
        .attr("class","label")
        .attr("title", name)
        .text(name)
        .style("fill", function(d) { return c(j); })
        .on("mouseover", mouseover)
        .on("mouseout", mouseout)
        .append("title").text(fullName);
    }

    element.innerHTML = '';
    element.appendChild(fragment);
    console.log('render time:', (new Date) - startTime);
  }

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

  function truncate(str, maxLength, suffix) {
    if (str.length > maxLength) {
      str = str.substring(0, maxLength + 1);
      str = str.substring(0, Math.min(str.length, str.lastIndexOf(" ")));
      str = str + suffix;
    }
    return str;
  }

  $scope.render = _render;
  $scope.setRange = _setRange;
});